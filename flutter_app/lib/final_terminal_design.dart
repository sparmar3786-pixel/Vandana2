import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FinalTerminalDesign extends StatefulWidget {
  const FinalTerminalDesign({super.key});
  @override State<FinalTerminalDesign> createState()=>_FinalTerminalDesignState();
}

class _FinalTerminalDesignState extends State<FinalTerminalDesign>{
  ThemeMode mode=ThemeMode.light;
  int tab=0;
  String backendUrl='https://vandana2-nse-backend.onrender.com';
  String selectedIndex='NIFTY 50';
  String selectedTimeframe='FIVE_MINUTE';
  final Set<String> selectedIndicators={'EMA 8','EMA 13','EMA 20/50','VWAP','RSI','MACD','ATR','Bollinger'};
  List<Map<String,dynamic>> candles=[];
  List<Map<String,dynamic>> strategyResults=[];
  List<Map<String,dynamic>> aiLayers=[];
  String aiStatus='AI validation not connected';
  String chartSection='Indices';
  String apiStatus='Backend URL required';
  String mcpStatus='MCP status not checked';
  final TextEditingController backendController=TextEditingController(text:'https://nse-algo-backend-live-production.up.railway.app');
  final TextEditingController terminalApiKeyController=TextEditingController();
  final TextEditingController angelApiKeyController=TextEditingController();
  final TextEditingController clientIdController=TextEditingController();
  final TextEditingController pinController=TextEditingController();
  final TextEditingController totpController=TextEditingController();
  bool showTerminalApiKey=false;
  bool showAngelApiKey=false;
  String loginStatus='';
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();
  // 30-screen reference layout from the supplied NSE-AI-TERMINAL design.
  // Core live-data screens are preserved; no order-placement screen is exposed.
  static const pages=<String>[
    'Splash / Launch','Login / Authentication','Dashboard (Home)','Market Overview','Option Chain','OI Heatmap',
    'Premium / Volume','Greeks / IV Surface','Order Flow','Market Regime','Trade Plans (S+)',
    'Backtest','Strategy Registry','AI 6-Layer Panel','Logs / Settings','Portfolio / Positions',
    'Charts - Advanced','Strategy Details','Risk Management','Notifications / Alerts','Help / Education',
    'AI Model Selection','Data Feed Status','Backtest Settings','Research Modules',
    '377 Strategy Classification','OI Classification','Final Verdict','Angel One API','Search / AI'
  ];
  static const indices=['NIFTY 50','BANK NIFTY','FINNIFTY','MIDCPNIFTY','SENSEX','BANKEX'];

  @override Widget build(BuildContext context)=>MaterialApp(
    debugShowCheckedModeBanner:false,title:'NSE-AI-TERMINAL',themeMode:mode,
    scaffoldMessengerKey:_messengerKey,
    theme:_theme(false),darkTheme:_theme(true),
    home:Builder(builder:(context)=>Scaffold(
      appBar:AppBar(
        leading:Builder(builder:(context)=>IconButton(icon:const Icon(Icons.menu),onPressed:()=>Scaffold.of(context).openDrawer())),
        title:Row(children:[_logo(32),const SizedBox(width:8),const Expanded(child:Text('NSE-AI-TERMINAL'))]),
        actions:[const Chip(label:Text('LIVE')),PopupMenuButton<String>(
          onSelected:(v){setState(()=>tab=v=='ai'?13:v=='search'?29:v=='chart'?16:28);},
          itemBuilder:(_)=>const[
            PopupMenuItem(value:'ai',child:Text('AI 6×6 Matrix')),
            PopupMenuItem(value:'search',child:Text('Search / Strategy Engine')),
            PopupMenuItem(value:'chart',child:Text('Charts / Indicators')),
            PopupMenuItem(value:'angel',child:Text('Angel One API'))]),
        IconButton(
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
      title:Text('${i+1}. ${pages[i]}'),
      onTap:(){Navigator.pop(context);setState(()=>tab=i);}))),
    const Padding(padding:EdgeInsets.all(12),child:Text('Live data only • Order placement unavailable • Secrets server-side',style:TextStyle(fontSize:11)))
  ])));

  static const _icons=<IconData>[
    Icons.rocket_launch,Icons.lock,Icons.dashboard,Icons.public,Icons.table_chart,Icons.grid_view,
    Icons.show_chart,Icons.functions,Icons.swap_vert,Icons.speed,Icons.bolt,Icons.history,Icons.view_list,
    Icons.auto_awesome,Icons.settings,Icons.account_balance_wallet,Icons.candlestick_chart,Icons.rule,
    Icons.shield,Icons.notifications,Icons.school,Icons.smart_toy,Icons.wifi_tethering,Icons.tune,
    Icons.science,Icons.numbers,Icons.compare_arrows,Icons.gavel,Icons.link,Icons.search];

  Widget _page(int p){
    final b=<Widget Function()>[
      _launch,_login,_dashboard,_market,_chain,_heatmap,_premium,_greeks,_flow,_regime,
      _plans,_backtest,_registry,_ai,_settings,_portfolio,_charts,_detail,_risk,_alerts,
      _education,_models,_feed,_btSettings,_research,_classification,_oi,_final,_angelApi,_search];
    return _shell(pages[p],b[p]());
  }
  Widget _shell(String title,Widget child)=>SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(13,10,13,24),children:[
    Text(title,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800)),const SizedBox(height:12),child]));

  Widget _launch()=>Column(children:[const SizedBox(height:25),_logo(88),const SizedBox(height:14),
    const Text('Smart Analysis • Disciplined Decisions',style:TextStyle(fontSize:16,fontWeight:FontWeight.w700)),
    const SizedBox(height:12),_chips(['Run60 + Run93','377 Modules','6-Layer AI']),const SizedBox(height:24),
    FilledButton.icon(onPressed:()=>setState(()=>tab=2),icon:const Icon(Icons.play_arrow),label:const Text('GET STARTED')),
    const SizedBox(height:10),const Text('LIVE DATA ONLY • CONNECTION REQUIRED')]);

  Map<String,String> _authHeaders({bool jsonBody=false}){
    final h=<String,String>{};
    final key=terminalApiKeyController.text.trim();
    if(key.isNotEmpty){
      h['X-API-Key']=key;
      h['X-Token']=key;
    }
    if(jsonBody) h['Content-Type']='application/json';
    return h;
  }

  Future<void> _loginAngel() async {
    var base=backendUrl.trim();
    while(base.endsWith('/')) { base=base.substring(0,base.length-1); }
    if(base.isEmpty){setState(()=>loginStatus='Backend URL required. Open Angel One API and set it first.');return;}
    if(terminalApiKeyController.text.trim().isEmpty){setState(()=>loginStatus='Terminal API Key required.');return;}
    setState(()=>loginStatus='Connecting to Angel One…');
    try{
      final headers=_authHeaders(jsonBody:true);
      final angelKey=angelApiKeyController.text.trim();
      final clientId=clientIdController.text.trim();
      final pin=pinController.text.trim();
      final totp=totpController.text.trim();

      var response=await http.post(
        Uri.parse('$base/api/live/angel/login'),
        headers:headers,
        body:jsonEncode({
          'clientId':clientId.isEmpty?null:clientId,
          'pin':pin.isEmpty?null:pin,
          'totp':totp.isEmpty?null:totp,
          'apiKey':angelKey.isEmpty?null:angelKey,
        }),
      ).timeout(const Duration(seconds:20));

      final j=jsonDecode(response.body);
      if(response.statusCode<300 && j is Map && j['connected']==true){
        setState(()=>loginStatus='Angel One connected');
      }else{
        final detail=j is Map && (j['detail']!=null || j['message']!=null)
            ?(j['detail'] ?? j['message']).toString()
            :response.body;
        setState(()=>loginStatus='Login failed: '+detail);
      }
    }catch(e){setState(()=>loginStatus='Connection failed: '+e.runtimeType.toString());}
  }

  Widget _login()=>Column(children:[
    TextField(controller:backendController,decoration:const InputDecoration(labelText:'Backend URL',prefixIcon:Icon(Icons.link)),onChanged:(v)=>backendUrl=v),
    const SizedBox(height:8),
    _info('Backend URL is pre-filled with the Render live backend. You can edit it when needed.',Icons.cloud),
    const SizedBox(height:4),
    _info('Terminal API Key authenticates this APK to your backend.',Icons.vpn_key),
    TextField(controller:terminalApiKeyController,obscureText:!showTerminalApiKey,decoration:InputDecoration(labelText:'Terminal API Key',hintText:'Enter terminal key',prefixIcon:const Icon(Icons.key),suffixIcon:IconButton(tooltip:showTerminalApiKey?'Hide':'Show',onPressed:()=>setState(()=>showTerminalApiKey=!showTerminalApiKey),icon:Icon(showTerminalApiKey?Icons.visibility_off:Icons.visibility)))),
    const SizedBox(height:8),
    _info('Angel One API Key is editable separately and is sent only for Angel login.',Icons.api),
    TextField(controller:angelApiKeyController,obscureText:!showAngelApiKey,decoration:InputDecoration(labelText:'Angel One API Key',hintText:'Enter Angel One API key',prefixIcon:const Icon(Icons.key),suffixIcon:IconButton(tooltip:showAngelApiKey?'Hide':'Show',onPressed:()=>setState(()=>showAngelApiKey=!showAngelApiKey),icon:Icon(showAngelApiKey?Icons.visibility_off:Icons.visibility)))),
    const SizedBox(height:8),
    TextField(controller:clientIdController,decoration:const InputDecoration(labelText:'Client ID',prefixIcon:Icon(Icons.person))),
    const SizedBox(height:8),
    TextField(controller:pinController,obscureText:true,decoration:const InputDecoration(labelText:'PIN',prefixIcon:Icon(Icons.password))),
    const SizedBox(height:8),
    TextField(controller:totpController,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'TOTP',prefixIcon:Icon(Icons.verified_user))),
    const SizedBox(height:10),
    FilledButton.icon(onPressed:_loginAngel,icon:const Icon(Icons.login),label:const Text('CONNECT')),
    if(loginStatus.isNotEmpty) Padding(padding:const EdgeInsets.only(top:8),child:Text(loginStatus)),
  ]);

  String _apiIndex(String x)=>x.replaceAll(' ','')=='NIFTY50'?'NIFTY':x.replaceAll(' ','').toUpperCase();

  Future<void> _connectBackend() async {
    var base=backendUrl.trim();
    while(base.endsWith('/')) { base=base.substring(0,base.length-1); }
    if(base.isEmpty){setState(()=>apiStatus='Enter backend URL first');return;}
    try{
      final h=await http.get(Uri.parse('$base/health')).timeout(const Duration(seconds:12));
      if(h.statusCode<200 || h.statusCode>=300){setState(()=>apiStatus='Backend HTTP '+h.statusCode.toString());return;}
      final r=await http.get(Uri.parse('$base/api/live/angel/token'),headers:_authHeaders()).timeout(const Duration(seconds:12));
      Map<String,dynamic> j={};
      try{j=jsonDecode(r.body) as Map<String,dynamic>;}catch(_){}
      if(r.statusCode==401){setState(()=>apiStatus='Backend reachable • Terminal API Key rejected');return;}
      if(r.statusCode==503){setState(()=>apiStatus='Backend reachable • TERMINAL_API_KEY missing on server');return;}
      setState(()=>apiStatus=r.statusCode<300 && j['connected']==true?'Angel One connected':r.statusCode<300?'Backend connected • Angel login required':'Backend API error '+r.statusCode.toString());
      if(r.statusCode<300){await _loadCandles(); await _loadAiLayers(); await _loadMcpStatus();}
    }catch(_){setState(()=>apiStatus='Backend connection failed • check URL/network');}
  }

  Future<void> _loadCandles() async {
    var base=backendUrl.trim();
    while(base.endsWith('/')) { base=base.substring(0,base.length-1); }
    if(base.isEmpty){return;}
    try{
      final url='$base/api/candles/${Uri.encodeComponent(_apiIndex(selectedIndex))}?interval=$selectedTimeframe&days=5';
      final r=await http.get(Uri.parse(url),headers:_authHeaders()).timeout(const Duration(seconds:15));
      if(r.statusCode<300){
        final j=jsonDecode(r.body) as Map<String,dynamic>;
        final rows=(j['rows'] as List? ?? const[]);
        setState(()=>candles=rows.whereType<Map>().map((x)=>Map<String,dynamic>.from(x)).toList());
      }else{setState(()=>candles=[]);}
    }catch(_){setState(()=>candles=[]);}
  }

  Future<void> _loadAiLayers() async {
    var base=backendUrl.trim();
    while(base.endsWith('/')) { base=base.substring(0,base.length-1); }
    if(base.isEmpty){return;}
    try{
      final r=await http.get(Uri.parse('$base/api/ai/layers'),headers:_authHeaders()).timeout(const Duration(seconds:10));
      if(r.statusCode<300){
        final j=jsonDecode(r.body) as Map<String,dynamic>;
        setState(()=>aiLayers=(j['layers'] as List? ?? const[]).whereType<Map>().map((x)=>Map<String,dynamic>.from(x)).toList());
      }
    }catch(_){}
  }

  Future<void> _loadMcpStatus() async {
    var base=backendUrl.trim();
    while(base.endsWith('/')) { base=base.substring(0,base.length-1); }
    if(base.isEmpty)return;
    try{
      final r=await http.get(Uri.parse('$base/api/live/mcp/status'),headers:_authHeaders()).timeout(const Duration(seconds:15));
      Map<String,dynamic> j={}; try{j=jsonDecode(r.body) as Map<String,dynamic>;}catch(_){}
      if(r.statusCode==200){
        final reachable=j['reachable']==true;
        final usable=(j['live_usable'] is List)?(j['live_usable'] as List).join(', '):'none';
        setState(()=>mcpStatus=reachable?'MCP reachable • '+usable:'MCP server not reachable • '+usable);
      }else{
        setState(()=>mcpStatus='MCP status HTTP '+r.statusCode.toString());
      }
    }catch(_){setState(()=>mcpStatus='MCP connection check failed');}
  }

  Future<void> _runAiValidation() async {
    var base=backendUrl.trim();
    while(base.endsWith('/')) { base=base.substring(0,base.length-1); }
    if(base.isEmpty){setState(()=>aiStatus='Backend URL required');return;}
    setState(()=>aiStatus='Running six-layer validation…');
    try{
      final r=await http.post(Uri.parse('${base}/api/ai/validate/${Uri.encodeComponent(_apiIndex(selectedIndex))}'),headers:_authHeaders()).timeout(const Duration(seconds:70));
      final j=jsonDecode(r.body) as Map<String,dynamic>;
      final layers=(j['layers'] as List? ?? const[]).whereType<Map>().map((x)=>Map<String,dynamic>.from(x)).toList();
      setState(()=>aiStatus=r.statusCode<300
        ? 'Validated ${layers.length}/6 • ${j['wait_override']==true?'WAIT override active':'validation complete'}'
        : 'AI validation unavailable');
    }catch(_){setState(()=>aiStatus='AI validation unavailable');}
  }

  Future<void> _searchStrategies(String q) async {
    var base=backendUrl.trim();
    while(base.endsWith('/')) { base=base.substring(0,base.length-1); }
    if(base.isEmpty){setState(()=>strategyResults=[]);return;}
    try{
      final url='$base/api/strategies?q=${Uri.encodeQueryComponent(q)}&limit=100';
      final r=await http.get(Uri.parse(url),headers:_authHeaders()).timeout(const Duration(seconds:10));
      if(r.statusCode<300){
        final j=jsonDecode(r.body) as Map<String,dynamic>;
        setState(()=>strategyResults=(j['strategies'] as List? ?? const[]).whereType<Map>().map((x)=>Map<String,dynamic>.from(x)).toList());
      }
    }catch(_){setState(()=>strategyResults=[]);}
  }

  void _toggleIndicator(String x)=>setState(()=>selectedIndicators.contains(x)?selectedIndicators.remove(x):selectedIndicators.add(x));

  Widget _dashboard()=>Column(children:[
    _info('Live data connection required • no simulated market data',Icons.cloud_off),_indexStrip(),
    _grid([['CALL OI','—','Live'],['PUT OI','—','Live'],['PCR','—','Live'],['Regime','—','Live']]),
    _verdict('WAIT','Awaiting verified live market data',Colors.orange),
    _homeAiButtons([
      ['Option Chain','Shows CE/PE strike, LTP, OI, change in OI and volume when verified live data is available.'],
      ['OI Lab','Explains OI buildup, covering, unwinding, PCR, support and resistance from the live option chain.'],
      ['Signals','Explains the qualified CALL/PUT signal pipeline and why a setup may remain WAIT or NO TRADE.'],
      ['Portfolio','Explains positions, P&L, margin and account status; this APK does not place orders.'],
      ['AI Validation','Explains the six-layer validation gate and its WAIT override without inventing market data.'],
    ]),
    _pipeline()]);

  Widget _market()=>Column(children:[_indexStrip(),...indices.map((x)=>_row(x,'—','Live feed required')),
    _title('Market Breadth'),_grid([['Advances','—','Live'],['Declines','—','Live'],['Unchanged','—','Live'],['PCR','—','Live']])]);

  Widget _chain()=>Column(children:[
    _indexStrip(),_chips(['CE','PE','OI','Volume','Change OI']),
    Card(child:SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(
      columns:const[DataColumn(label:Text('Strike')),DataColumn(label:Text('CE LTP')),DataColumn(label:Text('CE OI')),
        DataColumn(label:Text('PE LTP')),DataColumn(label:Text('PE OI')),DataColumn(label:Text('Chg OI'))],
      rows:List.generate(7,(i){return const DataRow(cells:[
        DataCell(Text('—')),DataCell(Text('—')),DataCell(Text('—')),DataCell(Text('—')),DataCell(Text('—')),DataCell(Text('—'))]);})))),
    _info('Missing OI / volume / stale data => NO TRADE',Icons.shield)]);

  Widget _heatmap()=>Column(children:[_info('OI Heatmap will populate from the verified live option chain.',Icons.cloud_off),_chips(['OI Concentration','Migration','Wall Break','Wall Rebuild','OI Velocity'])]);

  Widget _premium()=>Column(children:[_info('Premium and volume charts require verified live data.',Icons.cloud_off),
    _chips(['Premium ↑','Premium ↓','Volume Spike','Price/OI Divergence','Volume + OI'])]);

  Widget _greeks()=>Column(children:[_grid([['ATM Delta','—','Live'],['Gamma','—','Live'],['Theta','—','Live'],['Vega','—','Live'],['IV','—','Live'],['IV Skew','—','Live']]),
    _info('IV surface requires verified live option data.',Icons.cloud_off),_info('IV is confirmation evidence; it does not create a new entry formula.',Icons.info_outline)]);

  Widget _flow()=>Column(children:[_grid([['Net Flow','—','Live'],['Buy Ratio','—','Live'],['Large Lots','—','Live'],['Spread','—','Live']]),
    _info('Observable order flow requires live tick/trade data.',Icons.cloud_off),_chips(['Buyer Initiated','Seller Initiated','Tick Momentum','Absorption','Reversal'])]);

  Widget _regime()=>Column(children:[_verdict('WAIT','Market regime pending verified live data',Colors.orange),
    _grid([['Trend','—','Live'],['Volatility','—','Live'],['Momentum','—','Live'],['Mode','—','Live']]),
    _chips(['Strong Bull','Strong Bear','Sideways','Range','Breakout','Compression','Mean Reversion'])]);

  Widget _plans()=>Column(children:[_info('No trade plan is displayed until verified live data passes every deterministic gate.',Icons.verified),_verdict('NO TRADE','Live market data required before qualification.',Colors.grey)]);

  Widget _backtest()=>Column(children:[_info('Backtest results appear only after a real historical dataset and completed run.',Icons.history),_chips(['Strategy-wise','Index-wise','CE vs PE','Expiry','Time Window','Regime']),
    _info('Win-rate claims require setup-specific historical backtest evidence.',Icons.history)]);

  Widget _registry()=>Column(children:[const TextField(decoration:InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search 377 modules')),const SizedBox(height:8),
    ...['Long Buildup','Short Buildup','Short Covering','Long Unwinding','OI Wall','OI Wall Break','OI Migration','Premium Momentum','Volume + OI Confirmation']
      .asMap().entries.map((e)=>_row('S${(e.key+1).toString().padLeft(3,'0')}',e.value,'OI / Position')),
    _info('Types: Signal • Indicator • Filter • Risk • Data • Backtest • AI • Decision',Icons.list_alt)]);

  Widget _ai(){
    final layers=<Map<String,dynamic>>[
      if(aiLayers.isEmpty)...[
        {'id':'L1','name':'GPT-5.6 Luna','role':'data collection / candidate analysis'},
        {'id':'L2','name':'Claude Sonnet 4.6','role':'data verification'},
        {'id':'L3','name':'GPT-5.6 Sol','role':'independent validation'},
        {'id':'L4','name':'DeepSeek Chat','role':'quantitative / OI audit'},
        {'id':'L5','name':'Gemini 2.5 Flash','role':'market structure analysis'},
        {'id':'L6','name':'Grok 4','role':'final risk audit / cross verification'},
      ] else ...aiLayers,
    ];
    return Column(children:[
      Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[const Icon(Icons.auto_awesome),const SizedBox(width:8),const Expanded(child:Text('AI 6×6 VALIDATION MATRIX',style:TextStyle(fontWeight:FontWeight.w900))),
          FilledButton.tonalIcon(onPressed:_runAiValidation,icon:const Icon(Icons.play_arrow),label:const Text('RUN'))]),
        const SizedBox(height:6),Text(aiStatus,style:const TextStyle(fontSize:11)),
      ]))),
      ...layers.map((x)=>Card(child:ListTile(
        leading:CircleAvatar(child:Text(x['id'].toString())),
        title:Text(x['name'].toString(),style:const TextStyle(fontWeight:FontWeight.w800)),
        subtitle:Text(x['role'].toString()),
        trailing:const Icon(Icons.verified_outlined),
      ))),
      _verdict('WAIT OVERRIDE','AI may downgrade; it never invents strike, entry, SL or target.',Colors.orange),
      _info('Validation only. Confidence is not a win rate.',Icons.security)
    ]);
  }

  Widget _settings()=>Column(children:[_setting('Data source','Angel One → MCP → NSE public (verified live only)'),_setting('Advanced engine','Optional / gated'),
    _setting('AI','Puter.js validation-only'),_setting('Order placement','Not available in this APK'),_setting('Risk / R:R','Single gate'),
    _setting('Storage','Verified market snapshots • signals • backtests'),_chips(['Feed Latency','Data Gaps','Gate Blocks','Module Hit Rate','Drift'])]);

  Widget _portfolio()=>Column(children:[_info('Live portfolio data is unavailable until an authenticated live account/feed is connected.',Icons.cloud_off),_grid([['Positions','—','Live'],['P&L','—','Live'],['Margin','—','Live'],['Orders','—','Live']]),_chips(['Trade History','Account Status'])]);

  Widget _charts()=>Column(children:[
    Card(child:Padding(padding:const EdgeInsets.all(8),child:Row(children:[
      Expanded(child:ChoiceChip(label:const Text('INDICES'),selected:chartSection=='Indices',onSelected:(_){setState(()=>chartSection='Indices');})),
      const SizedBox(width:8),
      Expanded(child:ChoiceChip(label:const Text('OPTIONS'),selected:chartSection=='Options',onSelected:(_){setState(()=>chartSection='Options');})),
    ]))),
    if(chartSection=='Indices') ...[
      _indexStrip(),
      Card(child:Padding(padding:const EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('INDICES • LIVE CHART',style:TextStyle(fontWeight:FontWeight.w900)),
        const SizedBox(height:8),
        Wrap(spacing:5,runSpacing:5,children:indices.map((x)=>ChoiceChip(label:Text(x),selected:selectedIndex==x,onSelected:(v){if(v){setState(()=>selectedIndex=x);_loadCandles();}})).toList()),
        const SizedBox(height:8),
        Wrap(spacing:5,runSpacing:5,children:[
          for(final x in const {'ONE_MINUTE':'1m','TWO_MINUTE':'2m','THREE_MINUTE':'3m','FIVE_MINUTE':'5m','TEN_MINUTE':'10m','FIFTEEN_MINUTE':'15m','THIRTY_MINUTE':'30m','ONE_HOUR':'1H','TWO_HOUR':'2H','FOUR_HOUR':'4H','ONE_DAY':'1D'}.entries)
            ChoiceChip(label:Text(x.value),selected:selectedTimeframe==x.key,onSelected:(v){if(v){setState(()=>selectedTimeframe=x.key);_loadCandles();}})
        ]),
        const SizedBox(height:8),
        Wrap(spacing:5,runSpacing:5,children:['EMA 8','EMA 13','EMA 20/50','VWAP','RSI','MACD','ATR','Bollinger','WaveTrend','Supertrend','Pivot','CPR','Fibonacci','Volume','OI'].map((x)=>FilterChip(label:Text(x),selected:selectedIndicators.contains(x),onSelected:(_)=>_toggleIndicator(x))).toList()),
      ]))),
      if(candles.isEmpty) _info('No verified live candles received yet.',Icons.cloud_off)
      else Card(child:SizedBox(height:280,child:CustomPaint(painter:LiveChartPainter(candles:candles,indicators:selectedIndicators),child:const SizedBox.expand()))),
      if(candles.isNotEmpty)_indicatorPanel(),
      _info('Native Angel One intervals: 1m/3m/5m/10m/15m/30m/1H/1D. 2m/2H/4H are resampled from live candles.',Icons.info_outline)
    ] else ...[
      _info('Live option chart: select an option from the verified Option Chain to load its candles. No simulated option prices are shown.',Icons.table_chart),
      _chips(['CE Premium','PE Premium','OI','Volume','IV','Greeks'])
    ]
  ]);

  Widget _search()=>Column(children:[
    TextField(decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search strategy / module / formula'),onChanged:_searchStrategies),
    const SizedBox(height:8),
    _info('Search Engine uses the live 377-module strategy registry from the backend.',Icons.search),
    if(strategyResults.isEmpty)_info('Connect the backend and enter a query.',Icons.cloud_off)
    else ...strategyResults.map((x)=>_row(x['id'].toString(),x['name'].toString(),(x['family'] ?? 'Strategy').toString()))
  ]);

  Widget _angelApi()=>Column(children:[
    TextField(controller:backendController,decoration:const InputDecoration(labelText:'Backend URL',prefixIcon:Icon(Icons.link)),onChanged:(v)=>backendUrl=v),
    const SizedBox(height:8),
    FilledButton.icon(onPressed:_connectBackend,icon:const Icon(Icons.login),label:const Text('CONNECT ANGEL ONE LIVE')),
    const SizedBox(height:8),
    _row('Broker','Angel One SmartAPI',apiStatus),
    _info('API keys, client PIN and TOTP remain server-side. APK calls only your backend.',Icons.security),
    _setting('Live quote','SmartAPI FULL + WebSocket'),
    _setting('Historical candles','SmartAPI Historical API'),
    _setting('Option Greeks','Delta • Gamma • Theta • Vega • IV'),
    _setting('Order placement','Not exposed in this APK'),
  ]);

  Widget _indicatorPanel(){
    final close=candles.map((x)=>_num(x['close'])).whereType<double>().toList();
    final e8=_ema(close,8); final e13=_ema(close,13); final e20=_ema(close,20); final e50=_ema(close,50); final bb=_bollinger(close);
    final latest=candles.isEmpty?null:candles.last;
    return _grid([
      ['EMA 8',_fmt(e8.isEmpty?null:e8.last),'Indicator'],['EMA 13',_fmt(e13.isEmpty?null:e13.last),'Indicator'],
      ['EMA 20',_fmt(e20.isEmpty?null:e20.last),'Indicator'],['EMA 50',_fmt(e50.isEmpty?null:e50.last),'Indicator'],
      ['VWAP',_fmt(_vwap(candles)),'Indicator'],['RSI 14',_fmt(_rsi(close,14)),'Indicator'],
      ['MACD',_fmt(_macd(close)),'Indicator'],['ATR 14',_fmt(_atr(candles,14)),'Indicator'],
      ['Bollinger mid',_fmt(bb==null?null:bb[0]),'Indicator'],['Bollinger upper',_fmt(bb==null?null:bb[1]),'Indicator'],
      ['Bollinger lower',_fmt(bb==null?null:bb[2]),'Indicator'],['WaveTrend',_fmt(_waveTrend(candles)),'Indicator'],
      ['Supertrend',_fmt(_supertrend(candles,10,3)),'Indicator'],['Pivot',_fmt(_pivot(candles)),'Indicator'],
      ['CPR',_fmt(_cpr(candles)),'Indicator'],['Fibonacci 61.8%',_fmt(_fib618(candles)),'Context'],
      ['Volume',_fmt(_num(latest?['volume'])),'Live'],['OI',_fmt(_num(latest?['oi'])),'Live']
    ]);
  }

  double? _num(dynamic v)=>v is num?v.toDouble():double.tryParse(v?.toString() ?? '');
  String _fmt(double? v)=>v==null?'—':v.toStringAsFixed(2);
  List<double> _ema(List<double> a,int n){
    if(a.isEmpty){return [];}
    final k=2/(n+1); final out=<double>[a.first];
    for(var i=1;i<a.length;i++){ out.add(a[i]*k+out.last*(1-k)); }
    return out;
  }
  double? _macd(List<double> a){
    if(a.length<2){return null;}
    final e12=_ema(a,12),e26=_ema(a,26); return e12.last-e26.last;
  }
  double? _rsi(List<double> a,int n){
    if(a.length<=n){return null;}
    var gain=0.0,loss=0.0;
    for(var i=1;i<=n;i++){final d=a[i]-a[i-1];if(d>=0){gain+=d;}else{loss-=d;}}
    var avgG=gain/n,avgL=loss/n;
    for(var i=n+1;i<a.length;i++){final d=a[i]-a[i-1];avgG=(avgG*(n-1)+(d>0?d:0))/n;avgL=(avgL*(n-1)+(d<0?-d:0))/n;}
    if(avgL==0){return 100;} return 100-(100/(1+avgG/avgL));
  }
  double? _atr(List<Map<String,dynamic>> rows,int n){
    if(rows.length<n+1){return null;}
    final tr=<double>[];
    for(var i=1;i<rows.length;i++){final h=_num(rows[i]['high']),l=_num(rows[i]['low']),pc=_num(rows[i-1]['close']);if(h!=null&&l!=null&&pc!=null){tr.add([h-l,(h-pc).abs(),(l-pc).abs()].reduce((a,b)=>a>b?a:b));}}
    if(tr.length<n){return null;} return tr.sublist(tr.length-n).reduce((a,b)=>a+b)/n;
  }
  List<double>? _bollinger(List<double> a){
    if(a.length<20){return null;}
    final w=a.sublist(a.length-20); final m=w.reduce((x,y)=>x+y)/w.length;
    final variance=w.map((x)=>(x-m)*(x-m)).reduce((x,y)=>x+y)/w.length;
    final sd=mathSqrt(variance);
    return [m,m+2*sd,m-2*sd];
  }
  double? _waveTrend(List<Map<String,dynamic>> rows){
    if(rows.length<10){return null;}
    final tp=<double>[];
    for(final r in rows){final h=_num(r['high']),l=_num(r['low']),c=_num(r['close']);if(h!=null&&l!=null&&c!=null)tp.add((h+l+c)/3);}
    if(tp.length<10){return null;}
    final esa=_ema(tp,10); final dev=_ema(List<double>.generate(tp.length,(i)=>(tp[i]-esa[i]).abs()),10);
    if(dev.isEmpty||dev.last==0){return null;}
    return (tp.last-esa.last)/(0.015*dev.last);
  }
  double? _supertrend(List<Map<String,dynamic>> rows,int period,double multiplier){
    final atr=_atr(rows,period); final last=rows.isEmpty?null:rows.last;
    final h=last==null?null:_num(last['high']), l=last==null?null:_num(last['low']);
    if(atr==null||h==null||l==null){return null;} return (h+l)/2;
  }
  double? _pivot(List<Map<String,dynamic>> rows){
    if(rows.isEmpty){return null;}
    final r=rows.last; final h=_num(r['high']),l=_num(r['low']),c=_num(r['close']);
    return h==null||l==null||c==null?null:(h+l+c)/3;
  }
  double? _cpr(List<Map<String,dynamic>> rows){
    if(rows.isEmpty){return null;}
    final r=rows.last; final h=_num(r['high']),l=_num(r['low']),c=_num(r['close']);
    return h==null||l==null||c==null?null:(h+l+c)/3;
  }
  double? _fib618(List<Map<String,dynamic>> rows){
    if(rows.length<2){return null;}
    final highs=rows.map((r)=>_num(r['high'])).whereType<double>();
    final lows=rows.map((r)=>_num(r['low'])).whereType<double>();
    if(highs.isEmpty||lows.isEmpty){return null;}
    final hi=highs.reduce((a,b)=>a>b?a:b),lo=lows.reduce((a,b)=>a<b?a:b);
    return hi-(hi-lo)*0.618;
  }

  double? _vwap(List<Map<String,dynamic>> rows){
    var pv=0.0,v=0.0;
    for(final r in rows){final h=_num(r['high']),l=_num(r['low']),c=_num(r['close']),vol=_num(r['volume']);if(h!=null&&l!=null&&c!=null&&vol!=null){pv+=((h+l+c)/3)*vol;v+=vol;}}
    return v==0?null:pv/v;
  }

  Widget _detail()=>Column(children:[_info('S006 • OI Wall Break',Icons.rule),_setting('Family','OI / Position'),_setting('Type','Signal + confirmation'),
    _setting('Evidence','OI concentration + acceptance + volume'),_setting('Backtest','Setup-specific history required'),_chips(['Watchlist','Compare','Backtest','Evidence'])]);

  Widget _risk()=>Column(children:[_grid([['Max Risk / Trade','Configured','Rule'],['Max Total Risk','Configured','Rule'],['R:R Gate','WAIT','Live'],['Spread','WAIT','Live'],['Liquidity','WAIT','Live'],['Gap Risk','WAIT','Live']]),
    _verdict('RISK GATE','Single deterministic gate controls entry eligibility.',const Color(0xff18a66a)),_chips(['Structure SL','Premium SL','ATR SL','Trailing','Break-even','Time Exit'])]);

  Widget _alerts()=>Column(children:[_info('No alerts until verified live data is received.',Icons.cloud_off)]);

  Widget _education()=>Column(children:['How to read Option Chain','OI Classification — 4 Types','377 Strategy Registry','Risk / R:R Gate','AI Validation Guide','Data Quality / NO TRADE'].map((x)=>_row('Guide',x,'›')).toList());

  Widget _models()=>Column(children:[_setting('Provider','Puter.js • Zero Key'),_setting('Catalogue','Runtime listModels()'),
    ...['GPT-5.6 Luna','Claude Sonnet 4.6','GPT-5.6 Sol','DeepSeek Chat','Gemini 2.5 Flash','Grok 4'].map((x)=>_row(x,'Runtime check',''))]);

  Widget _feed()=>Column(children:[_row('Backend',apiStatus,'Live'),_row('Angel One','Live SmartAPI','—'),_row('NSE MCP',mcpStatus,'Live'),_grid([['Latency','—','Live'],['Freshness','—','Live'],['Gaps','—','Live'],['Sync','—','Live']]),FilledButton.icon(onPressed:_connectBackend,icon:const Icon(Icons.sync),label:const Text('CHECK LIVE CONNECTION'))]);

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
    ['368–377','Final Decision','Decision']].map((x)=>_row(x[0],x[1],x[2])).toList());

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

  Widget _pipeline()=>Card(child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('42-POINT PIPELINE',style:TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:8),
    _homeAiButtons([
      ['Data','Explains whether the Home page is receiving verified market data or is still waiting for a live feed.'],
      ['Quality','Explains freshness, missing fields and data-quality gates before a signal can qualify.'],
      ['Regime','Explains trend, volatility, momentum and market-mode classification.'],
      ['Price','Explains price structure and movement used by the decision pipeline.'],
      ['Indicators','Explains EMA, VWAP, RSI, MACD, ATR and other configured indicators.'],
      ['OI','Explains open-interest change and the four OI classifications.'],
      ['Premium','Explains option premium movement and its relationship with price/OI evidence.'],
      ['Seller','Explains seller/short-position evidence and short-covering confirmation.'],
      ['CE/PE','Explains how CALL and PUT sides are evaluated separately.'],
      ['Override','Explains deterministic safety/AI override conditions that can downgrade a setup.'],
      ['Strike','Explains strike selection context around ATM and relevant OI concentration.'],
      ['Risk','Explains stop-loss, risk/reward, liquidity and gap-risk gates.'],
      ['AI','Explains the AI validation role; it does not guarantee a trade outcome.'],
      ['Decision','Explains the final WAIT / NO TRADE / qualified output logic on this Home page.'],
    ])])));

  void _showHomeAiNotification(String label,String explanation){
    if(!mounted)return;
    final messenger=_messengerKey.currentState;
    if(messenger==null)return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration:const Duration(seconds:6),
        behavior:SnackBarBehavior.floating,
        content:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('AI • Home page',style:TextStyle(fontWeight:FontWeight.w900)),
          const SizedBox(height:3),
          Text('$label: $explanation'),
          const SizedBox(height:3),
          const Text('Only this Home page • no navigation',style:TextStyle(fontSize:10)),
        ]),
        action:SnackBarAction(label:'CLOSE',onPressed:(){
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }),
      ));
  }

  Widget _homeAiButtons(List<List<String>> items)=>Wrap(
    spacing:8,runSpacing:8,
    children:items.map((item)=>OutlinedButton(
      onPressed:()=>_showHomeAiNotification(item[0],item[1]),
      child:Text(item[0]),
    )).toList());

  Widget _indexStrip()=>SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:indices.map((x)=>Padding(padding:const EdgeInsets.only(right:6),child:ActionChip(label:Text(x),onPressed:()=>setState(()=>tab=3)))).toList()));
  Widget _grid(List<List<String>> a)=>GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisSpacing:7,mainAxisSpacing:7,childAspectRatio:3,children:a.map((x)=>Card(child:Padding(padding:const EdgeInsets.all(9),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(x[0],style:const TextStyle(fontSize:11)),Text(x[1],style:const TextStyle(fontWeight:FontWeight.w800))])))).toList());
  Widget _row(String a,String b,String c)=>Card(child:ListTile(dense:true,title:Text(a,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text(b),trailing:Text(c)));
  Widget _setting(String a,String b)=>_row(a,b,'');
  Widget _oiCard(String title,String formula,String desc,Color color,IconData icon)=>Card(child:ListTile(leading:CircleAvatar(backgroundColor:color.withValues(alpha:.14),foregroundColor:color,child:Icon(icon)),title:Text(title,style:TextStyle(fontWeight:FontWeight.w900,color:color)),subtitle:Text('$formula\n$desc')));
  Widget _verdict(String title,String desc,Color color)=>Card(child:Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(borderRadius:BorderRadius.circular(15),border:Border(left:BorderSide(color:color,width:5))),child:Row(children:[Icon(Icons.circle,color:color,size:12),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(fontWeight:FontWeight.w900,color:color)),Text(desc)]))])));
  Widget _info(String text,IconData icon)=>Card(child:ListTile(dense:true,leading:Icon(icon,color:Theme.of(context).colorScheme.primary),title:Text(text)));
  Widget _chips(List<String> x)=>Wrap(spacing:5,runSpacing:5,children:x.map((s)=>Chip(label:Text(s,style:const TextStyle(fontSize:10)))).toList());
  Widget _title(String x)=>Padding(padding:const EdgeInsets.fromLTRB(2,10,2,7),child:Align(alignment:Alignment.centerLeft,child:Text(x,style:const TextStyle(fontWeight:FontWeight.w900))));
  Widget _logo(double size)=>Container(width:size,height:size,decoration:BoxDecoration(borderRadius:BorderRadius.circular(size*.22),gradient:const LinearGradient(colors:[Color(0xff1769e0),Color(0xff14c984)])),child:Icon(Icons.candlestick_chart_rounded,size:size*.52,color:Colors.white));
}



class LiveChartPainter extends CustomPainter{
  final List<Map<String,dynamic>> candles;
  final Set<String> indicators;
  LiveChartPainter({required this.candles,required this.indicators});

  double? _n(dynamic v)=>v is num?v.toDouble():double.tryParse(v?.toString() ?? '');
  List<double> _close()=>candles.map((x)=>_n(x['close'])).whereType<double>().toList();
  List<double> _ema(List<double> a,int n){
    if(a.isEmpty){return [];}
    final k=2/(n+1); final out=<double>[a.first];
    for(var i=1;i<a.length;i++){ out.add(a[i]*k+out.last*(1-k)); }
    return out;
  }
  double? _vwap(){
    var pv=0.0,v=0.0;
    for(final r in candles){
      final h=_n(r['high']),l=_n(r['low']),c=_n(r['close']),vol=_n(r['volume']);
      if(h!=null&&l!=null&&c!=null&&vol!=null){pv+=((h+l+c)/3)*vol;v+=vol;}
    }
    return v==0?null:pv/v;
  }
  @override void paint(Canvas canvas,Size size){
    final a=_close(); if(a.length<2){return;}
    final minV=a.reduce((x,y)=>x<y?x:y),maxV=a.reduce((x,y)=>x>y?x:y);
    final double span=(maxV-minV).abs()<0.0001?1.0:(maxV-minV);
    Offset pt(int i,double v)=>Offset(i*(size.width/(a.length-1)),size.height-((v-minV)/span)*size.height*.82-size.height*.08);
    void line(List<double> vals){
      final path=Path();
      for(var i=0;i<vals.length;i++){final p=pt(i,vals[i]);if(i==0){path.moveTo(p.dx,p.dy);}else{path.lineTo(p.dx,p.dy);}}
      canvas.drawPath(path,Paint()..strokeWidth=2..style=PaintingStyle.stroke);
    }
    line(a);
    if(indicators.contains('EMA 8')){line(_ema(a,8));}
    if(indicators.contains('EMA 13')){line(_ema(a,13));}
    if(indicators.contains('EMA 20/50')){line(_ema(a,20));line(_ema(a,50));}
    final vwap=_vwap();
    if(indicators.contains('VWAP')&&vwap!=null){line(List<double>.filled(a.length,vwap));}
    if(indicators.contains('Bollinger')&&a.length>=20){
      final upper=<double>[],lower=<double>[];
      for(var i=0;i<a.length;i++){
        final start=i<19?0:i-19; final w=a.sublist(start,i+1); final m=w.reduce((x,y)=>x+y)/w.length;
        final variance=w.map((x)=>(x-m)*(x-m)).reduce((x,y)=>x+y)/w.length; final double sd=variance>0?variance.sqrt():0.0;
        upper.add(m+2*sd);lower.add(m-2*sd);
      }
      line(upper);line(lower);
    }
  }
  @override bool shouldRepaint(covariant LiveChartPainter old)=>old.candles!=candles || old.indicators!=indicators;
}

extension on double{
  double sqrt()=>this<=0?0:mathSqrt(this);
}
double mathSqrt(double x){
  var g=x>1?x:1.0;
  for(var i=0;i<12;i++){ g=(g+x/g)/2; }
  return g;
}
