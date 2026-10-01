import 'package:flutter/material.dart';

class FinalTerminalDesign extends StatefulWidget {
  const FinalTerminalDesign({super.key});
  @override State<FinalTerminalDesign> createState()=>_FinalTerminalDesignState();
}

class _FinalTerminalDesignState extends State<FinalTerminalDesign>{
  ThemeMode mode=ThemeMode.dark;
  int tab=2;
  static const pages=<String>[
    'Launch','Login','Dashboard','Market Overview','Option Chain','OI Heatmap',
    'Premium / Volume','Greeks / IV','Order Flow','Market Regime','Trade Plans',
    'Backtest','Strategy Registry','AI 6-Layer','Logs / Settings','Portfolio',
    'Charts','Strategy Detail','Risk Management','Alerts','Education',
    'AI Model Selection','Data Feed Status','Backtest Settings','Research Modules',
    '377 Classification','OI Classification','Final Verdict','Light Theme','Dark Theme'
  ];
  static const indices=['NIFTY 50','BANK NIFTY','FINNIFTY','MIDCPNIFTY','SENSEX','BANKEX'];

  @override Widget build(BuildContext context)=>MaterialApp(
    debugShowCheckedModeBanner:false,title:'NSE-AI-TERMINAL',themeMode:mode,
    theme:_theme(false),darkTheme:_theme(true),
    home:Builder(builder:(context)=>Scaffold(
      appBar:AppBar(
        leading:IconButton(icon:const Icon(Icons.menu),onPressed:()=>Scaffold.of(context).openDrawer()),
        title:Row(children:[_logo(32),const SizedBox(width:8),const Expanded(child:Text('NSE-AI-TERMINAL'))]),
        actions:[const Chip(label:Text('PAPER')),IconButton(
          onPressed:()=>setState(()=>mode=mode==ThemeMode.dark?ThemeMode.light:ThemeMode.dark),
          icon:Icon(mode==ThemeMode.dark?Icons.light_mode:Icons.dark_mode))]
      ),
      drawer:_drawer(context),body:_page(tab),
      bottomNavigationBar:NavigationBar(
        selectedIndex:tab==2?0:tab==4?1:tab==10?2:tab==15?3:4,
        onDestinationSelected:(i)=>setState(()=>tab=[2,4,10,15,14][i]),
        destinations:const[
          NavigationDestination(icon:Icon(Icons.dashboard_outlined),label:'Home'),
          NavigationDestination(icon:Icon(Icons.table_chart_outlined),label:'Chain'),
          NavigationDestination(icon:Icon(Icons.bolt_outlined),label:'Signals'),
          NavigationDestination(icon:Icon(Icons.account_balance_wallet_outlined),label:'Portfolio'),
          NavigationDestination(icon:Icon(Icons.more_horiz),label:'More')]))));

  ThemeData _theme(bool dark)=>ThemeData(
    useMaterial3:true,brightness:dark?Brightness.dark:Brightness.light,
    colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff1769e0),brightness:dark?Brightness.dark:Brightness.light),
    scaffoldBackgroundColor:dark?const Color(0xff07111d):const Color(0xfff5f8fc),
    cardTheme:CardThemeData(color:dark?const Color(0xff0e1a29):Colors.white,elevation:0,
      margin:const EdgeInsets.only(bottom:10),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15))),
    navigationBarTheme:NavigationBarThemeData(backgroundColor:dark?const Color(0xff0e1a29):Colors.white));

  Drawer _drawer(BuildContext context)=>Drawer(child:SafeArea(child:Column(children:[
    Padding(padding:const EdgeInsets.all(18),child:Row(children:[_logo(44),const SizedBox(width:10),
      const Expanded(child:Text('NSE-AI-TERMINAL\n42-point • 377 modules',style:TextStyle(fontWeight:FontWeight.w800)))])),
    SwitchListTile(title:const Text('Dark mode'),value:mode==ThemeMode.dark,
      onChanged:(v)=>setState(()=>mode=v?ThemeMode.dark:ThemeMode.light)),const Divider(),
    Expanded(child:ListView.builder(itemCount:pages.length,itemBuilder:(_,i)=>ListTile(
      dense:true,selected:tab==i,leading:Icon(_icons[i]),
      title:Text((i+1).toString()+'. '+pages[i]),
      onTap:(){Navigator.pop(context);setState(()=>tab=i);}))),
    const Padding(padding:EdgeInsets.all(12),child:Text('Paper-first • Live orders OFF • Secrets server-side',style:TextStyle(fontSize:11)))
  ])));

  static const _icons=<IconData>[
    Icons.rocket_launch,Icons.lock,Icons.dashboard,Icons.public,Icons.table_chart,Icons.grid_view,
    Icons.show_chart,Icons.functions,Icons.swap_vert,Icons.speed,Icons.bolt,Icons.history,Icons.view_list,
    Icons.auto_awesome,Icons.settings,Icons.account_balance_wallet,Icons.candlestick_chart,Icons.rule,
    Icons.shield,Icons.notifications,Icons.school,Icons.smart_toy,Icons.wifi_tethering,Icons.tune,
    Icons.science,Icons.numbers,Icons.compare_arrows,Icons.gavel,Icons.light_mode,Icons.dark_mode];

  Widget _page(int p){
    final b=<Widget Function()>[
      _launch,_login,_dashboard,_market,_chain,_heatmap,_premium,_greeks,_flow,_regime,
      _plans,_backtest,_registry,_ai,_settings,_portfolio,_charts,_detail,_risk,_alerts,
      _education,_models,_feed,_btSettings,_research,_classification,_oi,_final,_light,_dark];
    return _shell(pages[p],b[p]());
  }
  Widget _shell(String title,Widget child)=>SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(13,10,13,24),children:[
    Text(title,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800)),const SizedBox(height:12),child]));

  Widget _launch()=>Column(children:[const SizedBox(height:25),_logo(88),const SizedBox(height:14),
    const Text('Smart Analysis • Disciplined Decisions',style:TextStyle(fontSize:16,fontWeight:FontWeight.w700)),
    const SizedBox(height:12),_chips(['Run60 + Run93','377 Modules','6-Layer AI']),const SizedBox(height:24),
    FilledButton.icon(onPressed:()=>setState(()=>tab=2),icon:const Icon(Icons.play_arrow),label:const Text('GET STARTED')),
    const SizedBox(height:10),const Text('PAPER / DEMO MODE • LIVE ORDERS OFF')]);

  Widget _login()=>Column(children:[
    _info('Angel One credentials stay server-side',Icons.lock),
    const TextField(decoration:InputDecoration(labelText:'Client ID',prefixIcon:Icon(Icons.person))),
    const SizedBox(height:8),const TextField(obscureText:true,decoration:InputDecoration(labelText:'PIN',prefixIcon:Icon(Icons.password))),
    const SizedBox(height:8),const TextField(decoration:InputDecoration(labelText:'TOTP',prefixIcon:Icon(Icons.verified_user))),
    const SizedBox(height:10),FilledButton(onPressed:()=>setState(()=>tab=2),child:const Text('CONNECT')),
    TextButton(onPressed:()=>setState(()=>tab=2),child:const Text('USE DEMO MODE'))]);

  Widget _dashboard()=>Column(children:[
    _info('Angel One / Data Layer • Connected • Paper-first',Icons.cloud_done),_indexStrip(),
    _grid([['CALL OI','12.4M','+2.3%'],['PUT OI','11.8M','-1.1%'],['PCR','0.95','Neutral'],['Regime','Bullish','Expansion']]),
    _verdict('WAIT','No qualifying setup after all gates',Colors.orange),
    _chips(['Option Chain','OI Lab','Signals','Portfolio','AI Validation']),_pipeline()]);

  Widget _market()=>Column(children:[_indexStrip(),...indices.map((x)=>_row(x,_ltp(x),'+0.51%')),
    _title('Market Breadth'),_grid([['Advances','32',''],['Declines','17',''],['Unchanged','1',''],['PCR','0.95','Neutral']])]);

  Widget _chain()=>Column(children:[
    _indexStrip(),_chips(['CE','PE','OI','Volume','Change OI']),
    Card(child:SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(
      columns:const[DataColumn(label:Text('Strike')),DataColumn(label:Text('CE LTP')),DataColumn(label:Text('CE OI')),
        DataColumn(label:Text('PE LTP')),DataColumn(label:Text('PE OI')),DataColumn(label:Text('Chg OI'))],
      rows:List.generate(7,(i){final s=24700+(i-3)*50;return DataRow(cells:[
        DataCell(Text(s.toString())),DataCell(Text((102.3-i*8.1).toStringAsFixed(2))),
        DataCell(Text((15.2-i*.9).toStringAsFixed(1)+'L')),DataCell(Text((112.4-i*5.6).toStringAsFixed(2))),
        DataCell(Text((8.2+i*1.1).toStringAsFixed(1)+'L')),DataCell(Text(i.isEven?'+12.4K':'-8.1K'))]);}))),
    _info('Missing OI / volume / stale data => NO TRADE',Icons.shield)]);

  Widget _heatmap()=>Column(children:[
    ...[['24,600','8.4L','6.1L'],['24,650','10.2L','7.4L'],['24,700','14.9L','9.1L'],['24,750','12.1L','12.8L'],['24,800','7.8L','15.3L']].map((r)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[
      SizedBox(width:62,child:Text(r[0],style:const TextStyle(fontWeight:FontWeight.w800))),Expanded(child:LinearProgressIndicator(value:double.parse(r[1].replaceAll('L',''))/16)),
      const SizedBox(width:8),Text('CE '+r[1]),const SizedBox(width:10),Text('PE '+r[2])])))),
    _chips(['OI Concentration','Migration','Wall Break','Wall Rebuild','OI Velocity'])]);

  Widget _premium()=>Column(children:[_chart('Premium Momentum',[38,42,41,50,56,61,58,70,76,73]),
    _chart('Volume / OI Confirmation',[18,20,25,22,32,40,37,44,49,53]),
    _chips(['Premium ↑','Premium ↓','Volume Spike','Price/OI Divergence','Volume + OI'])]);

  Widget _greeks()=>Column(children:[_grid([['ATM Delta','0.52',''],['Gamma','0.018',''],['Theta','-4.2',''],['Vega','12.4',''],['IV','14.2%',''],['IV Skew','+0.8%','']]),
    _chart('IV Surface / Skew',[35,39,45,42,50,57,53,61,59,65]),_info('IV is confirmation evidence; it does not create a new entry formula.',Icons.info_outline)]);

  Widget _flow()=>Column(children:[_grid([['Net Flow','+12.4K',''],['Buy Ratio','68%',''],['Large Lots','23%',''],['Spread','0.18%','']]),
    _chart('Observable Order Flow',[22,27,25,31,36,34,42,48,46,55]),_chips(['Buyer Initiated','Seller Initiated','Tick Momentum','Absorption','Reversal'])]);

  Widget _regime()=>Column(children:[_verdict('BULL / EXPANSION','Trend Up • Volatility Low • Momentum Positive',const Color(0xff18a66a)),
    _grid([['Trend','Uptrend',''],['Volatility','Low',''],['Momentum','Positive',''],['Mode','Expansion','']]),
    _chips(['Strong Bull','Strong Bear','Sideways','Range','Breakout','Compression','Mean Reversion'])]);

  Widget _plans()=>Column(children:[_info('Only genuinely qualifying complete plans are shown. No fabricated padding.',Icons.verified),
    _plan('CALL','24,700','102.30','94.50','112.40','1:1.2'),_plan('CALL','24,800','81.20','74.00','96.80','1:1.2'),
    _plan('PUT','24,600','96.40','110.20','87.60','1:1.1'),_plan('CALL','24,900','63.10','58.00','71.20','1:1.7'),
    _plan('PUT','24,500','76.80','67.50','88.40','1:1.8')]);

  Widget _backtest()=>Column(children:[_grid([['Trades','1,284',''],['Avg R','1.8',''],['Max DD','12.3%',''],['Expectancy','+0.42R',''],['Profit Factor','1.61',''],['Streak','8 / 5','']]),
    _chart('Equity Curve',[20,24,22,29,31,28,36,40,37,46,51,48]),_chips(['Strategy-wise','Index-wise','CE vs PE','Expiry','Time Window','Regime']),
    _info('Win-rate claims require setup-specific historical backtest evidence.',Icons.history)]);

  Widget _registry()=>Column(children:[const TextField(decoration:InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search 377 modules')),const SizedBox(height:8),
    ...['Long Buildup','Short Buildup','Short Covering','Long Unwinding','OI Wall','OI Wall Break','OI Migration','Premium Momentum','Volume + OI Confirmation']
      .asMap().entries.map((e)=>_row('S'+(e.key+1).toString().padLeft(3,'0'),e.value,'OI / Position')),
    _info('Types: Signal • Indicator • Filter • Risk • Data • Backtest • AI • Decision',Icons.list_alt)]);

  Widget _ai()=>Column(children:[...['L1 • GPT-5.6 Luna','L2 • Claude Sonnet 4.6','L3 • GPT-5.6 Sol','L4 • DeepSeek Chat','L5 • Gemini 2.5 Flash','L6 • Grok 4']
      .map((x)=>_row(x,'AGREE','Validation only')),
    _verdict('WAIT OVERRIDE','AI may downgrade; it never invents strike, entry, SL or target.',Colors.orange),
    _info('Puter.js listModels() is checked at runtime.',Icons.auto_awesome)]);

  Widget _settings()=>Column(children:[_setting('Data source','Angel One → MCP → NSE public → Demo'),_setting('Advanced engine','Optional / gated'),
    _setting('AI','Puter.js validation-only'),_setting('Live orders','OFF'),_setting('Risk / R:R','Single gate'),
    _setting('Storage','Ticks • snapshots • signals • backtests'),_chips(['Feed Latency','Data Gaps','Gate Blocks','Module Hit Rate','Drift'])]);

  Widget _portfolio()=>Column(children:[_metric('Today P&L','+₹2,146','Paper'),_row('NIFTY 50 CE 24,700','Qty 75 • Avg ₹120.50','+₹3,366'),
    _row('BANK NIFTY PE 52,000','Qty 50 • Avg ₹210','-₹1,580'),_chips(['Paper Order','Modify','Cancel','Trade History'])]);

  Widget _charts()=>Column(children:[_chart('NIFTY 50 • 5m',[40,43,41,49,47,55,61,58,68,73,70,80]),
    _chips(['1m','2m','3m','5m','10m','15m','30m','1H','2H','4H','1D']),_chips(['EMA 8/13','VWAP','RSI','MACD','ATR','Bollinger'])]);

  Widget _detail()=>Column(children:[_info('S006 • OI Wall Break',Icons.rule),_setting('Family','OI / Position'),_setting('Type','Signal + confirmation'),
    _setting('Evidence','OI concentration + acceptance + volume'),_setting('Backtest','Setup-specific history required'),_chips(['Watchlist','Compare','Backtest','Evidence'])]);

  Widget _risk()=>Column(children:[_grid([['Max Risk / Trade','1.0%',''],['Max Total Risk','5.0%',''],['R:R Gate','PASS',''],['Spread','PASS',''],['Liquidity','PASS',''],['Gap Risk','PASS','']]),
    _verdict('RISK GATE','Single deterministic gate controls entry eligibility.',const Color(0xff18a66a)),_chips(['Structure SL','Premium SL','ATR SL','Trailing','Break-even','Time Exit'])]);

  Widget _alerts()=>Column(children:[_row('10:24','CALL signal candidate','High'),_row('10:18','Data quality OK','Info'),_row('10:09','Regime changed','Info'),_row('09:41','Risk limit check','OK'),_row('09:30','Market open','Info')]);

  Widget _education()=>Column(children:['How to read Option Chain','OI Classification — 4 Types','377 Strategy Registry','Risk / R:R Gate','AI Validation Guide','Data Quality / NO TRADE'].map((x)=>_row('Guide',x,'›')).toList());

  Widget _models()=>Column(children:[_setting('Provider','Puter.js • Zero Key'),_setting('Catalogue','Runtime listModels()'),
    ...['GPT-5.6 Luna','Claude Sonnet 4.6','GPT-5.6 Sol','DeepSeek Chat','Gemini 2.5 Flash','Grok 4'].map((x)=>_row(x,'Available',''))]);

  Widget _feed()=>Column(children:[_row('Angel One','Connected','✓'),_row('NSE Public','Standby','✓'),_row('NSE MCP','Connected','✓'),_row('Demo','Fallback',''),
    _grid([['Latency','320 ms',''],['Freshness','OK',''],['Gaps','0',''],['Sync','OK','']])]);

  Widget _btSettings()=>Column(children:[_setting('Strategy family','All families'),_setting('Time range','3 months'),_setting('Index','NIFTY 50'),_setting('Mode','Walk-forward'),
    _chips(['Run Backtest','Out-of-Sample','Monte Carlo','Sensitivity','Slippage','Transaction Cost'])]);

  Widget _research()=>Column(children:[_row('1','Volatility Surface Engine','Optional'),_row('2','Vega-Weighted Order Flow','Optional'),
    _row('3','Delta/Vega Information Decomposition','Optional'),_row('4','Cross-Option Flow Engine','Optional'),
    _row('5','Multi-Leg Strategy Recognition','Optional'),_row('6','Trade-Classification Engine','Optional'),
    _info('Enable only with observable tick/trade-level data; no hidden-order claims.',Icons.science)]);

  Widget _classification()=>Column(children:[
    ['1–28','OI / Position','Signal'],['29–44','Premium / Price','Signal'],['45–54','Volume','Indicator'],['55–72','CE / PE','Signal'],
    ['73–90','Seller / Short Covering','Signal'],['91–110','Strike / Option Chain','Feature'],['111–122','Support / Resistance','Feature'],
    ['123–149','Trend / Price Action','Signal'],['150–167','RSI / MACD / Volatility','Indicator'],['168–184','Greeks / IV','Indicator'],
    ['185–202','Expiry','Filter'],['203–219','Liquidity / Microstructure','Filter'],['220–234','Trap / Reversal','Signal'],
    ['235–246','Market Regime','Filter'],['247–260','Quant / Statistical','Indicator'],['261–274','Cross-Index / Breadth','Signal'],
    ['275–284','Fibonacci / Classical','Feature'],['285–305','Entry / Exit / Risk','Risk'],['306–317','Signal Intelligence','Filter'],
    ['318–332','Data / Reliability','Data Quality'],['333–354','Backtest / Validation','Backtest'],['355–367','AI / Strategy Discovery','AI'],
    ['368–377','Final Decision','Decision']].map((x)=>_row(x[0],x[1],x[2])));

  Widget _oi()=>Column(children:[
    _oiCard('LONG BUILDUP','Premium ↑ + OI ↑','New buying / bullish evidence',const Color(0xff18a66a),Icons.trending_up),
    _oiCard('SHORT BUILDUP','Premium ↓ + OI ↑','New short positioning / bearish evidence',const Color(0xffe64b5d),Icons.trending_down),
    _oiCard('SHORT COVERING','Premium ↑ + OI ↓','Short positions closing / reversal evidence',const Color(0xff1769e0),Icons.replay),
    _oiCard('LONG UNWINDING','Premium ↓ + OI ↓','Long positions closing / weakening evidence',const Color(0xffc98218),Icons.south),
    _info('Classification is evidence, not a guaranteed directional outcome.',Icons.info_outline)]);

  Widget _final()=>Column(children:[
    _verdict('CALL BUY','Only after CALL qualification + all gates pass',const Color(0xff18a66a)),
    _verdict('PUT BUY','Only after PUT qualification + all gates pass',const Color(0xffe64b5d)),
    _verdict('WAIT','Conflict / uncertainty / weak confirmation / AI override',Colors.orange),
    _verdict('NO TRADE','No complete qualifying setup or data-quality failure',Colors.grey),
    _info('These are the only four final outputs.',Icons.gavel)]);

  Widget _light()=>_themeCard(false);
  Widget _dark()=>_themeCard(true);
  Widget _themeCard(bool dark)=>Card(color:dark?const Color(0xff0b1727):Colors.white,child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('NSE-AI-TERMINAL',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:dark?Colors.white:const Color(0xff132238))),
    const SizedBox(height:12),Row(children:[Expanded(child:_preview('NIFTY 50','24,689.75','+0.51%')),const SizedBox(width:8),Expanded(child:_preview('PCR','0.95','Neutral'))]),
    const SizedBox(height:12),Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(borderRadius:BorderRadius.circular(13),color:dark?const Color(0xff12233a):const Color(0xffedf5ff)),
      child:const Row(children:[Icon(Icons.pause_circle_outline,color:Colors.orange),SizedBox(width:8),Text('WAIT • No qualifying setup')]))])));

  Widget _pipeline()=>Card(child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('42-POINT PIPELINE',style:TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:8),
    _chips(['Data','Quality','Regime','Price','Indicators','OI','Premium','Seller','CE/PE','Override','Strike','Risk','AI','Decision'])])));

  Widget _indexStrip()=>SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:indices.map((x)=>Padding(padding:const EdgeInsets.only(right:6),child:ActionChip(label:Text(x),onPressed:()=>setState(()=>tab=3)))).toList()));
  Widget _grid(List<List<String>> a)=>GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisSpacing:7,mainAxisSpacing:7,childAspectRatio:3,children:a.map((x)=>Card(child:Padding(padding:const EdgeInsets.all(9),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(x[0],style:const TextStyle(fontSize:11)),Text(x[1],style:const TextStyle(fontWeight:FontWeight.w800))])))).toList());
  Widget _row(String a,String b,String c)=>Card(child:ListTile(dense:true,title:Text(a,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text(b),trailing:Text(c)));
  Widget _setting(String a,String b)=>_row(a,b,'');
  Widget _metric(String a,String b,String c)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a),Text(b,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900)),Text(c)])));
  Widget _plan(String side,String strike,String entry,String sl,String target,String rr)=>Card(child:ListTile(leading:_badge(side),title:Text(side+' • '+strike),subtitle:Text('Entry '+entry+' • SL '+sl+' • T1 '+target),trailing:Text('R:R '+rr,style:const TextStyle(fontWeight:FontWeight.w800))));
  Widget _oiCard(String title,String formula,String desc,Color color,IconData icon)=>Card(child:ListTile(leading:CircleAvatar(backgroundColor:color.withOpacity(.14),foregroundColor:color,child:Icon(icon)),title:Text(title,style:TextStyle(fontWeight:FontWeight.w900,color:color)),subtitle:Text(formula+'\\n'+desc)));
  Widget _verdict(String title,String desc,Color color)=>Card(child:Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(borderRadius:BorderRadius.circular(15),border:Border(left:BorderSide(color:color,width:5))),child:Row(children:[Icon(Icons.circle,color:color,size:12),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(fontWeight:FontWeight.w900,color:color)),Text(desc)]))])));
  Widget _chart(String title,List<int> values)=>Card(child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:10),SizedBox(height:110,child:CustomPaint(painter:_Spark(values,Theme.of(context).colorScheme.primary)))])));
  Widget _info(String text,IconData icon)=>Card(child:ListTile(dense:true,leading:Icon(icon,color:Theme.of(context).colorScheme.primary),title:Text(text)));
  Widget _chips(List<String> x)=>Wrap(spacing:5,runSpacing:5,children:x.map((s)=>Chip(label:Text(s,style:const TextStyle(fontSize:10)))).toList());
  Widget _title(String x)=>Padding(padding:const EdgeInsets.fromLTRB(2,10,2,7),child:Align(alignment:Alignment.centerLeft,child:Text(x,style:const TextStyle(fontWeight:FontWeight.w900))));
  Widget _logo(double size)=>Container(width:size,height:size,decoration:BoxDecoration(borderRadius:BorderRadius.circular(size*.22),gradient:const LinearGradient(colors:[Color(0xff1769e0),Color(0xff14c984)])),child:Icon(Icons.candlestick_chart_rounded,size:size*.52,color:Colors.white));
  Widget _badge(String s)=>Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:5),decoration:BoxDecoration(borderRadius:BorderRadius.circular(8),color:(s=='CALL'?const Color(0xff18a66a):const Color(0xffe64b5d)).withOpacity(.13)),child:Text(s,style:TextStyle(fontWeight:FontWeight.w900,color:s=='CALL'?const Color(0xff18a66a):const Color(0xffe64b5d))));
  Widget _preview(String a,String b,String c)=>Container(padding:const EdgeInsets.all(9),decoration:BoxDecoration(borderRadius:BorderRadius.circular(11),border:Border.all(color:Theme.of(context).dividerColor)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a,style:const TextStyle(fontSize:10)),Text(b,style:const TextStyle(fontWeight:FontWeight.w900)),Text(c,style:const TextStyle(fontSize:10))]));
  String _ltp(String x)=>{'NIFTY 50':'24,689.75','BANK NIFTY':'52,317.20','FINNIFTY':'23,482.10','MIDCPNIFTY':'12,345.60','SENSEX':'81,742.20','BANKEX':'56,210.75'}[x]??'—';
}

class _Spark extends CustomPainter{
  final List<int> v; final Color c; const _Spark(this.v,this.c);
  @override void paint(Canvas canvas,Size size){
    if(v.length<2)return;
    final lo=v.reduce((a,b)=>a<b?a:b).toDouble(),hi=v.reduce((a,b)=>a>b?a:b).toDouble(),r=(hi-lo)==0?1:hi-lo;
    final p=Paint()..color=c..strokeWidth=3..style=PaintingStyle.stroke..strokeCap=StrokeCap.round;final path=Path();
    for(var i=0;i<v.length;i++){final x=i*size.width/(v.length-1),y=size.height-((v[i]-lo)/r)*size.height*.82-size.height*.08;if(i==0){path.moveTo(x,y);}else{path.lineTo(x,y);}}
    canvas.drawPath(path,p);
  }
  @override bool shouldRepaint(covariant _Spark old)=>old.v!=v||old.c!=c;
}
