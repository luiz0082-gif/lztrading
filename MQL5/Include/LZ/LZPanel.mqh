//+------------------------------------------------------------------+
//|                                                    LZPanel.mqh   |
//|  LZ Design System - painel operacional "HUD" (v2.0)              |
//|                                                                  |
//|  v1 (compativel): Header, Strip, Section, KV, KV2, Bar, Gap.     |
//|  v2 (novo): HeaderEx (chips de estado + relogio), StripHero,     |
//|  Hero (numero grande), Steps (pipeline segmentado), ChipFlow     |
//|  (chips com quebra de linha), Button (acento/pressionado),       |
//|  escala (%) e opacidade (%) do fundo.                            |
//|                                                                  |
//|  Regras: sem animacao nem piscar (objetos reaproveitados por     |
//|  nome); informacao critica nunca depende de hover; o botao       |
//|  minimizar/restaurar existe nos dois estados e sobrevive a       |
//|  redesenho. Somente ASCII neste arquivo.                         |
//|  Doc: docs/PAINEL_DS.md                                          |
//+------------------------------------------------------------------+
#ifndef LZ_PANEL_MQH
#define LZ_PANEL_MQH

//==================================================================
// TOKENS - cor
//==================================================================
#define LZ_BG          C'7,11,20'      // fundo do painel
#define LZ_SURFACE     C'12,18,32'     // superficie base
#define LZ_SURFACE2    C'18,27,48'     // superficie elevada (strip, chips)
#define LZ_LINE        C'32,46,76'     // hairline / trilho de barra
#define LZ_ACCENT      C'0,224,255'    // ciano - marca / foco / etapa concluida
#define LZ_ACCENT_DIM  C'0,96,120'     // ciano apagado - bordas ativas
#define LZ_PROFIT      C'0,255,157'    // lucro / ok / armado
#define LZ_LOSS        C'255,59,107'   // perda / erro / kill switch
#define LZ_WARN        C'255,184,0'    // bloqueio / atencao
#define LZ_GOLD        C'255,214,10'   // meta / alvo
#define LZ_INFO        C'125,145,255'  // informativo / posicao / etapa ativa
#define LZ_SELL        C'255,122,69'   // lado vendedor (compra usa LZ_ACCENT)
#define LZ_TEXT        C'226,234,248'  // texto primario
#define LZ_MUTED       C'112,130,162'  // texto secundario / rotulos

//==================================================================
// TOKENS - tipografia e espacamento (px a 100%)
//==================================================================
#define LZ_FONT        "Consolas"              // numeros e dados
#define LZ_FONT_UI     "Segoe UI Semibold"     // titulos (v1)
#define LZ_FONT_HEAD   "Bahnschrift SemiBold"  // titulos/rotulos v2 (fallback do Windows se ausente)
#define LZ_PAD         12                // margem lateral interna
#define LZ_ROW         17                // altura de linha de dados
#define LZ_HEADER_H    44
#define LZ_HEADER2_H   52
#define LZ_STRIP_H     28
#define LZ_HERO_STRIP_H 38
#define LZ_SECTION_H   22
#define LZ_BAR_H       32
#define LZ_CHAR_W      7                 // largura media Consolas 9pt (px)
#define LZ_CHAR_W8     6                 // largura media Consolas 8pt (px)

//--- mistura linear de cores: alpha 0..255 = peso de 'a' sobre 'b'
color LZ_Mix(const color a, const color b, const int alpha)
{
   int al = (int)MathMax(0, MathMin(255, alpha));
   int ar = (int)(a & 0xFF),         br = (int)(b & 0xFF);
   int ag = (int)((a >> 8) & 0xFF),  bg = (int)((b >> 8) & 0xFF);
   int ab = (int)((a >> 16) & 0xFF), bb = (int)((b >> 16) & 0xFF);
   int r = (ar * al + br * (255 - al)) / 255;
   int g = (ag * al + bg * (255 - al)) / 255;
   int bl = (ab * al + bb * (255 - al)) / 255;
   return (color)(r | (g << 8) | (bl << 16));
}

//--- estados do componente Steps
#define LZ_STEP_PENDING 0
#define LZ_STEP_ACTIVE  1
#define LZ_STEP_DONE    2
#define LZ_STEP_FAILED  3

//==================================================================
// CLZPanel
//==================================================================
class CLZPanel
{
private:
   string m_p;               // prefixo dos objetos
   int    m_x, m_y, m_w;
   int    m_cy;              // cursor vertical (relativo ao topo do painel, px a 100%)
   int    m_cx;              // cursor horizontal do ChipFlow
   int    m_nr, m_nl;        // contadores de retangulos / labels do frame
   int    m_maxr, m_maxl;    // maximo ja criado (limpeza de sobras)
   bool   m_min;
   int    m_lastH;           // altura do frame anterior (fundo nao encolhe entre frames)
   int    m_pct;             // escala do painel (%)
   int    m_opacity;         // opacidade do fundo (%)
   string m_minId;           // id do botao minimizar/restaurar

   string Name(const string kind, const int i) { return m_p + kind + IntegerToString(i); }
   int    P(const int v) const { return (int)MathRound((double)v * (double)m_pct / 100.0); }
   int    F(const int s) const { return (int)MathMax(7, MathRound((double)s * (double)m_pct / 100.0)); }

   // so grava a propriedade se o valor mudou: sem escrita redundante nao ha repaint intermediario
   void SetI(const string n, const ENUM_OBJECT_PROPERTY_INTEGER prop, const long v)
   {
      if(ObjectGetInteger(0, n, prop) != v) ObjectSetInteger(0, n, prop, v);
   }
   void SetS(const string n, const ENUM_OBJECT_PROPERTY_STRING prop, const string v)
   {
      if(ObjectGetString(0, n, prop) != v) ObjectSetString(0, n, prop, v);
   }

   color PanelBg()
   {
      if(m_opacity >= 100) return LZ_BG;
      long raw = 0;
      if(!ChartGetInteger(0, CHART_COLOR_BACKGROUND, 0, raw)) raw = (long)clrBlack;
      return LZ_Mix(LZ_BG, (color)raw, (int)MathRound(255.0 * m_opacity / 100.0));
   }

   void Rect(const int x, const int y, const int w, const int h,
             const color bg, const color border)
   {
      string n = Name("r", m_nr++);
      if(ObjectFind(0, n) < 0)
      {
         ObjectCreate(0, n, OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, n, OBJPROP_BACK, false);
         ObjectSetInteger(0, n, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      }
      SetI(n, OBJPROP_XDISTANCE, m_x + P(x));
      SetI(n, OBJPROP_YDISTANCE, m_y + P(y));
      SetI(n, OBJPROP_XSIZE, MathMax(1, P(w)));
      SetI(n, OBJPROP_YSIZE, MathMax(1, P(h)));
      SetI(n, OBJPROP_BGCOLOR, bg);
      SetI(n, OBJPROP_COLOR, border);
      if(m_nr > m_maxr) m_maxr = m_nr;
   }

   void TextA(const int x, const int y, const string t, const color c, const int size,
              const ENUM_ANCHOR_POINT anchor, const string font)
   {
      string n = Name("l", m_nl++);
      if(ObjectFind(0, n) < 0)
      {
         ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, n, OBJPROP_BACK, false);
      }
      SetI(n, OBJPROP_ANCHOR, anchor);
      SetI(n, OBJPROP_XDISTANCE, m_x + P(x));
      SetI(n, OBJPROP_YDISTANCE, m_y + P(y));
      SetI(n, OBJPROP_COLOR, c);
      SetI(n, OBJPROP_FONTSIZE, F(size));
      SetS(n, OBJPROP_FONT, font);
      SetS(n, OBJPROP_TEXT, t);
      if(m_nl > m_maxl) m_maxl = m_nl;
   }

   // right=true: 'x' e a borda direita do texto
   void Text(const int x, const int y, const string t, const color c,
             const int size = 9, const bool right = false, const string font = LZ_FONT)
   {
      TextA(x, y, t, c, size, right ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_UPPER, font);
   }

   void Chip(const int rightEdge, const int y, const string t, const color c)
   {
      int w = StringLen(t) * LZ_CHAR_W + 14;
      Rect(rightEdge - w, y, w, 18, LZ_SURFACE2, c);
      Text(rightEdge - w + 7, y + 3, t, c, 9);
   }

   // chip v2: borda em tom apagado da propria cor (visual "neon" discreto)
   int Chip8(const int rightEdge, const int y, const string t, const color c)
   {
      int w = StringLen(t) * LZ_CHAR_W8 + 14;
      Rect(rightEdge - w, y, w, 18, LZ_SURFACE2, LZ_Mix(c, LZ_SURFACE2, 120));
      Text(rightEdge - w + 7, y + 3, t, c, 8);
      return w;
   }

   void MinButton()
   {
      string n = m_p + m_minId;
      if(ObjectFind(0, n) < 0)
      {
         ObjectCreate(0, n, OBJ_BUTTON, 0, 0, 0);
         ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
         ObjectSetString(0, n, OBJPROP_FONT, LZ_FONT);
         ObjectSetInteger(0, n, OBJPROP_ZORDER, 10);
      }
      SetI(n, OBJPROP_XSIZE, P(20));
      SetI(n, OBJPROP_YSIZE, P(18));
      SetI(n, OBJPROP_FONTSIZE, F(10));
      SetI(n, OBJPROP_XDISTANCE, m_x + P(m_w - 28));
      SetI(n, OBJPROP_YDISTANCE, m_y + P(9));
      SetI(n, OBJPROP_BGCOLOR, LZ_SURFACE2);
      SetI(n, OBJPROP_BORDER_COLOR, LZ_ACCENT_DIM);
      SetI(n, OBJPROP_COLOR, LZ_ACCENT);
      SetS(n, OBJPROP_TEXT, m_min ? "+" : "-");
   }

   void Sweep()
   {
      // remove objetos que sobraram de um frame maior
      for(int i = m_nr; i < m_maxr; i++) ObjectDelete(0, Name("r", i));
      for(int i = m_nl; i < m_maxl; i++) ObjectDelete(0, Name("l", i));
      m_maxr = m_nr; m_maxl = m_nl;
   }

public:
   CLZPanel() : m_p("LZP_"), m_x(12), m_y(22), m_w(400), m_cy(0), m_cx(0),
                m_nr(0), m_nl(0), m_maxr(0), m_maxl(0), m_min(false), m_lastH(LZ_HEADER_H),
                m_pct(100), m_opacity(100), m_minId("btn") {}

   void Init(const string prefix, const int x, const int y, const int w = 400)
   {
      m_p = prefix; m_x = x; m_y = y; m_w = w;
      m_maxr = m_maxl = 0; m_lastH = LZ_HEADER_H;
      string gv = m_p + "min";
      m_min = GlobalVariableCheck(gv) && GlobalVariableGet(gv) > 0.5;
      ObjectsDeleteAll(0, m_p);
   }

   //--- v2: configuracao opcional (chamar depois de Init)
   void SetScale(const int pct)          { m_pct = (int)MathMax(50, MathMin(250, pct)); }
   void SetOpacity(const int pct)        { m_opacity = (int)MathMax(0, MathMin(100, pct)); }
   void SetMinButtonId(const string id)  { m_minId = id; }
   void SetMinimized(const bool v)       { m_min = v; }

   bool Expanded() const { return !m_min; }
   int  Y() const { return m_cy; }
   int  W() const { return m_w; }

   void Destroy() { ObjectsDeleteAll(0, m_p); m_maxr = m_maxl = 0; }

   // Chamar em OnChartEvent. true = estado mudou (redesenhar).
   bool OnEvent(const int id, const string &sparam)
   {
      if(id != CHARTEVENT_OBJECT_CLICK || sparam != m_p + m_minId) return false;
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      m_min = !m_min;
      GlobalVariableSet(m_p + "min", m_min ? 1.0 : 0.0);
      ObjectsDeleteAll(0, m_p);      // recria na ordem certa (z-order)
      m_maxr = m_maxl = 0; m_lastH = LZ_HEADER_H;
      return true;
   }

   //--- inicio do frame
   void Begin()
   {
      m_nr = 0; m_nl = 0; m_cy = 0; m_cx = 0;
      Rect(0, 0, m_w, m_lastH, PanelBg(), LZ_LINE);   // r0: fundo (mantem a altura do frame anterior)
   }

   //--- cabecalho v1: marca, subtitulo, chip de estado, botao minimizar
   void Header(const string title, const string sub, const string state, const color stateClr)
   {
      Rect(0, 0, m_w, 2, LZ_ACCENT, LZ_ACCENT);                     // faixa de acento
      Text(LZ_PAD, 8, title, LZ_TEXT, 10, false, LZ_FONT_UI);
      Text(LZ_PAD, 26, sub, LZ_MUTED, 8);
      Chip(m_w - 34, 9, state, stateClr);
      MinButton();
      m_cy = LZ_HEADER_H;
   }

   //--- cabecalho v2: faixa de acento na cor do estado, titulo grande, dois chips, relogio
   void HeaderEx(const string title, const string sub, const string chip1, const color c1,
                 const string chip2, const color c2, const string clock, const color accent)
   {
      Rect(0, 0, m_w, 2, accent, accent);
      Text(LZ_PAD, 7, title, LZ_TEXT, 14, false, LZ_FONT_HEAD);
      Text(LZ_PAD, 32, sub, LZ_MUTED, 8, false, LZ_FONT_HEAD);
      int right = m_w - 34;
      int w1 = Chip8(right, 9, chip1, c1);
      Chip8(right - w1 - 6, 9, chip2, c2);
      Text(m_w - LZ_PAD, 32, clock, LZ_MUTED, 8, true);
      MinButton();
      m_cy = LZ_HEADER2_H;
   }

   //--- linha de decisao: por que opera / nao opera
   void Strip(const string label, const string text, const color clr)
   {
      Rect(LZ_PAD - 4, m_cy, m_w - 2 * (LZ_PAD - 4), LZ_STRIP_H - 4, LZ_SURFACE2, LZ_LINE);
      Rect(LZ_PAD - 4, m_cy, 3, LZ_STRIP_H - 4, clr, clr);          // barra lateral de status
      Text(LZ_PAD + 6, m_cy + 5, label, LZ_MUTED, 8);
      Text(LZ_PAD + 6 + (StringLen(label) + 1) * 6, m_cy + 4, text, clr, 9);
      m_cy += LZ_STRIP_H;
   }

   //--- faixa de decisao v2 (destaque): rotulo pequeno em cima, texto grande, fundo tingido
   void StripHero(const string label, const string text, const color clr)
   {
      int x = LZ_PAD - 4;
      int w = m_w - 2 * (LZ_PAD - 4);
      Rect(x, m_cy, w, LZ_HERO_STRIP_H - 4, LZ_Mix(clr, LZ_BG, 28), LZ_Mix(clr, LZ_BG, 110));
      Rect(x, m_cy, 4, LZ_HERO_STRIP_H - 4, clr, clr);
      Text(LZ_PAD + 8, m_cy + 3, label, LZ_MUTED, 7, false, LZ_FONT_HEAD);
      Text(LZ_PAD + 8, m_cy + 14, text, clr, 11, false, LZ_FONT_HEAD);
      m_cy += LZ_HERO_STRIP_H;
   }

   //--- numero grande com rotulo e detalhe a direita (ex.: floating da posicao)
   void Hero(const string label, const string value, const color clr,
             const string side, const color sideClr)
   {
      Rect(LZ_PAD - 4, m_cy, m_w - 2 * (LZ_PAD - 4), 44, LZ_SURFACE, LZ_LINE);
      Rect(LZ_PAD - 4, m_cy, 3, 44, clr, clr);
      Text(LZ_PAD + 6, m_cy + 4, label, LZ_MUTED, 7, false, LZ_FONT_HEAD);
      Text(LZ_PAD + 6, m_cy + 16, value, clr, 16, false, LZ_FONT_HEAD);
      Text(m_w - LZ_PAD - 2, m_cy + 8, side, sideClr, 9, true);
      m_cy += 50;
   }

   //--- pipeline segmentado: states[i] = LZ_STEP_*
   void Steps(const string &labels[], const int &states[], const int n)
   {
      if(n <= 0) return;
      int gap = 4;
      int total = m_w - 2 * LZ_PAD;
      int w = (total - gap * (n - 1)) / n;
      for(int i = 0; i < n; i++)
      {
         int x = LZ_PAD + i * (w + gap);
         color col = LZ_LINE, tx = LZ_MUTED, bg = LZ_SURFACE;
         if(states[i] == LZ_STEP_DONE)        { col = LZ_ACCENT; tx = LZ_ACCENT; bg = LZ_Mix(LZ_ACCENT, LZ_BG, 30); }
         else if(states[i] == LZ_STEP_ACTIVE) { col = LZ_INFO;   tx = LZ_TEXT;   bg = LZ_Mix(LZ_INFO, LZ_BG, 40); }
         else if(states[i] == LZ_STEP_FAILED) { col = LZ_LOSS;   tx = LZ_LOSS;   bg = LZ_Mix(LZ_LOSS, LZ_BG, 40); }
         Rect(x, m_cy, w, 24, bg, LZ_LINE);
         Rect(x, m_cy + 21, w, 3, col, col);
         TextA(x + w / 2, m_cy + 4, labels[i], tx, 8, ANCHOR_UPPER, LZ_FONT_HEAD);
      }
      m_cy += 30;
   }

   //--- chips em linha com quebra automatica
   void ChipBegin() { m_cx = LZ_PAD; }
   void ChipFlow(const string t, const color c)
   {
      int w = StringLen(t) * LZ_CHAR_W8 + 14;
      if(m_cx + w > m_w - LZ_PAD && m_cx > LZ_PAD) { m_cx = LZ_PAD; m_cy += 24; }
      Chip8(m_cx + w, m_cy, t, c);
      m_cx += w + 6;
   }
   void ChipEnd() { m_cy += 24; m_cx = LZ_PAD; }

   //--- botao v2 (x,y relativos ao painel, px a 100%). Persiste entre redesenhos.
   void Button(const string id, const int x, const int y, const int w, const int h,
               const string text, const color accent, const bool pressed = false, const bool filled = false)
   {
      string n = m_p + id;
      if(ObjectFind(0, n) < 0)
      {
         ObjectCreate(0, n, OBJ_BUTTON, 0, 0, 0);
         ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, n, OBJPROP_ZORDER, 10);
      }
      color bg = pressed ? LZ_Mix(accent, LZ_SURFACE2, 90) : (filled ? LZ_Mix(accent, LZ_BG, 70) : LZ_SURFACE2);
      SetI(n, OBJPROP_XDISTANCE, m_x + P(x));
      SetI(n, OBJPROP_YDISTANCE, m_y + P(y));
      SetI(n, OBJPROP_XSIZE, MathMax(1, P(w)));
      SetI(n, OBJPROP_YSIZE, MathMax(1, P(h)));
      SetI(n, OBJPROP_BGCOLOR, bg);
      SetI(n, OBJPROP_BORDER_COLOR, LZ_Mix(accent, LZ_SURFACE2, 140));
      SetI(n, OBJPROP_COLOR, accent);
      SetI(n, OBJPROP_FONTSIZE, F(8));
      SetS(n, OBJPROP_FONT, LZ_FONT_HEAD);
      SetS(n, OBJPROP_TEXT, text);
      SetI(n, OBJPROP_STATE, false);
   }

   //--- titulo de secao (camada operacional)
   void Section(const string title)
   {
      int y = m_cy + 6;
      Rect(LZ_PAD, y + 1, 3, 10, LZ_ACCENT, LZ_ACCENT);
      Text(LZ_PAD + 9, y, title, LZ_MUTED, 8);
      int lx = LZ_PAD + 9 + StringLen(title) * 6 + 8;
      Rect(lx, y + 6, m_w - LZ_PAD - lx, 1, LZ_LINE, LZ_LINE);
      m_cy += LZ_SECTION_H;
   }

   //--- rotulo + valor alinhado a direita
   void KV(const string label, const string value, const color clr = LZ_TEXT)
   {
      Text(LZ_PAD, m_cy, label, LZ_MUTED, 9);
      Text(m_w - LZ_PAD, m_cy, value, clr, 9, true);
      m_cy += LZ_ROW;
   }

   //--- duas colunas
   void KV2(const string l1, const string v1, const color c1,
            const string l2, const string v2, const color c2)
   {
      int half = m_w / 2;
      Text(LZ_PAD, m_cy, l1, LZ_MUTED, 9);
      Text(half - 10, m_cy, v1, c1, 9, true);
      Text(half + 10, m_cy, l2, LZ_MUTED, 9);
      Text(m_w - LZ_PAD, m_cy, v2, c2, 9, true);
      m_cy += LZ_ROW;
   }

   //--- barra de progresso 0..100 com marcas em 25/50/75
   void Bar(const string label, const string value, const double pct, const color clr)
   {
      Text(LZ_PAD, m_cy, label, LZ_MUTED, 9);
      Text(m_w - LZ_PAD, m_cy, value, clr, 9, true);
      int bw = m_w - 2 * LZ_PAD;
      int by = m_cy + 18;
      double p = MathMax(0.0, MathMin(100.0, pct));
      Rect(LZ_PAD, by, bw, 6, LZ_LINE, LZ_LINE);
      int fw = (int)MathRound(bw * p / 100.0);
      Rect(LZ_PAD, by, MathMax(fw, 1), 6, fw > 0 ? clr : LZ_LINE, fw > 0 ? clr : LZ_LINE);  // sempre 1 rect (indices estaveis)
      for(int k = 1; k <= 3; k++)
         Rect(LZ_PAD + bw * k / 4, by, 1, 6, LZ_BG, LZ_BG);
      m_cy += LZ_BAR_H;
   }

   void Gap(const int h) { m_cy += h; }

   //--- fim do frame: ajusta fundo, remove sobras, redesenha
   void End()
   {
      int h = m_cy + 8;
      m_lastH = h;
      SetI(Name("r", 0), OBJPROP_YSIZE, MathMax(1, P(h)));
      Sweep();
      ChartRedraw(0);
   }
};

#endif
