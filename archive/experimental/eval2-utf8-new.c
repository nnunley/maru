## defn main
int main(int argc, char **argv) {
  oop _acc = nil;

static long ___L__1__eval_2El__1558[] = {
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__2__eval_2El__1558[] = {
  "r"
,
    _acc = (oop)___L__2__eval_2El__1558;
  _tmp1 = _acc;
  _acc = _fdopen_24stub;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _stdin = _acc;

static long ___L__3__eval_2El__1559[] = {
  _acc = LONG(1);
  _tmp1 = _acc;

static long ___L__4__eval_2El__1559[] = {
  "a"
,
    _acc = (oop)___L__4__eval_2El__1559;
  _tmp0 = _acc;
  _acc = _fdopen_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _stdout = _acc;

static long ___L__5__eval_2El__1560[] = {
  _acc = LONG(2);
  _tmp0 = _acc;

static long ___L__6__eval_2El__1560[] = {
  "a"
,
    _acc = (oop)___L__6__eval_2El__1560;
  _tmp1 = _acc;
  _acc = _fdopen_24stub;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _stderr = _acc;

static long ___L__7__eval_2El__1562[] = {
  _acc = _gc__initialise;
  _acc = ((oop (*)())_acc)();
  _acc = LONG(0);

static long ___L__8__eval_2El__1564[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _new_2D_3Carray_3E;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _symbols = _acc;
  _acc = (oop)&_symbols;
  _tmp1 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__9__eval_2El__1566[] = {

static long ___L__10__eval_2El__1566[] = {
  "t"
,
    _acc = (oop)___L__10__eval_2El__1566;
  _tmp1 = _acc;
  _acc = _intern;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _s__t = _acc;

static long ___L__11__eval_2El__1567[] = {

static long ___L__12__eval_2El__1567[] = {
  "."
,
    _acc = (oop)___L__12__eval_2El__1567;
  _tmp1 = _acc;
  _acc = _intern;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _s__dot = _acc;

static long ___L__13__eval_2El__1568[] = {

static long ___L__14__eval_2El__1568[] = {
  "set"
,
    _acc = (oop)___L__14__eval_2El__1568;
  _tmp1 = _acc;
  _acc = _intern;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _s__set = _acc;

static long ___L__15__eval_2El__1569[] = {

static long ___L__16__eval_2El__1569[] = {
  "define"
,
    _acc = (oop)___L__16__eval_2El__1569;
  _tmp1 = _acc;
  _acc = _intern;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _s__define = _acc;

static long ___L__17__eval_2El__1570[] = {

static long ___L__18__eval_2El__1570[] = {
  "lambda"
,
    _acc = (oop)___L__18__eval_2El__1570;
  _tmp1 = _acc;
  _acc = _intern;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _s__lambda = _acc;

static long ___L__19__eval_2El__1571[] = {

static long ___L__20__eval_2El__1571[] = {
  "let"
,
    _acc = (oop)___L__20__eval_2El__1571;
  _tmp1 = _acc;
  _acc = _intern;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _s__let = _acc;

static long ___L__21__eval_2El__1572[] = {

static long ___L__22__eval_2El__1572[] = {
  "quote"
,
    _acc = (oop)___L__22__eval_2El__1572;
  _tmp1 = _acc;
  _acc = _intern;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _s__quote = _acc;

static long ___L__23__eval_2El__1573[] = {

static long ___L__24__eval_2El__1573[] = {
  "quasiquote"
,
    _acc = (oop)___L__24__eval_2El__1573;
  _tmp1 = _acc;
  _acc = _intern;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _s__quasiquote = _acc;

static long ___L__25__eval_2El__1574[] = {

static long ___L__26__eval_2El__1574[] = {
  "unquote"
,
    _acc = (oop)___L__26__eval_2El__1574;
  _tmp1 = _acc;
  _acc = _intern;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _s__unquote = _acc;

static long ___L__27__eval_2El__1575[] = {

static long ___L__28__eval_2El__1575[] = {
  "unquote-splicing"
,
    _acc = (oop)___L__28__eval_2El__1575;
  _tmp1 = _acc;
  _acc = _intern;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _s__unquote__splicing = _acc;

static long ___L__29__eval_2El__1577[] = {
  _acc = (oop)&_globals;
  _tmp1 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__30__eval_2El__1579[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _new_2D_3Cenv_3E;
  _tmp0 = _tmp1;
  _tmp1 = _tmp0;
  _tmp2 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _globals = _acc;

static long ___L__31__eval_2El__1580[] = {
  _acc = _globals;
  _tmp2 = _acc;

static long ___L__32__eval_2El__1580[] = {
  "*globals*"
,
    _acc = (oop)___L__32__eval_2El__1580;
  _tmp0 = _acc;
  _acc = _intern;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _globals;
  _tmp1 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _tmp2 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _globals = _acc;

static long ___L__33__eval_2El__1582[] = {
  _acc = _globals;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = __3Cvariable_3E;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp1 = _acc;

static long ___L__34__eval_2El__1582[] = {
  "*input*"
,
    _acc = (oop)___L__34__eval_2El__1582;
  _tmp0 = _acc;
  _acc = _intern;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp1;
  _tmp1 = _tmp0;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _input = _acc;
  _acc = (oop)&_input;
  _tmp3 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__35__eval_2El__1583[] = {
  _acc = _globals;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = __3Cvariable_3E;
  _tmp1 = _acc;
  _acc = _tmp3;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp3 = _acc;

static long ___L__36__eval_2El__1583[] = {
  "*expanders*"
,
    _acc = (oop)___L__36__eval_2El__1583;
  _tmp0 = _acc;
  _acc = _intern;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp3;
  _tmp1 = _tmp0;
  _tmp2 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _expanders = _acc;
  _acc = (oop)&_expanders;
  _tmp2 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__37__eval_2El__1584[] = {
  _acc = _globals;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp2;
  _tmp1 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp2 = _acc;

static long ___L__38__eval_2El__1584[] = {
  "*encoders*"
,
    _acc = (oop)___L__38__eval_2El__1584;
  _tmp0 = _acc;
  _acc = _intern;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _tmp2 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _encoders = _acc;
  _acc = (oop)&_encoders;
  _tmp1 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__39__eval_2El__1585[] = {
  _acc = _globals;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = __3Cvariable_3E;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp1 = _acc;

static long ___L__40__eval_2El__1585[] = {
  "*evaluators*"
,
    _acc = (oop)___L__40__eval_2El__1585;
  _tmp0 = _acc;
  _acc = _intern;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp1;
  _tmp1 = _tmp0;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _evaluators = _acc;
  _acc = (oop)&_evaluators;
  _tmp3 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__41__eval_2El__1586[] = {
  _acc = _globals;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = __3Cvariable_3E;
  _tmp1 = _acc;
  _acc = _tmp3;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp3 = _acc;

static long ___L__42__eval_2El__1586[] = {
  "*applicators*"
,
    _acc = (oop)___L__42__eval_2El__1586;
  _tmp0 = _acc;
  _acc = _intern;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp3;
  _tmp1 = _tmp0;
  _tmp2 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _applicators = _acc;
  _acc = (oop)&_applicators;
  _tmp2 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__43__eval_2El__1588[] = {

static long ___L__44__eval_2El__1588[] = {
  "define"
,
    _acc = (oop)___L__44__eval_2El__1588;
  _tmp2 = _acc;
  _acc = _subr__define;
  _tmp0 = _acc;
  _acc = _define_2Dfsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__45__eval_2El__1589[] = {

static long ___L__46__eval_2El__1589[] = {
  "lambda"
,
    _acc = (oop)___L__46__eval_2El__1589;
  _tmp0 = _acc;
  _acc = _subr__lambda;
  _tmp2 = _acc;
  _acc = _define_2Dfsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__47__eval_2El__1590[] = {

static long ___L__48__eval_2El__1590[] = {
  "let"
,
    _acc = (oop)___L__48__eval_2El__1590;
  _tmp2 = _acc;
  _acc = _subr__let;
  _tmp0 = _acc;
  _acc = _define_2Dfsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__49__eval_2El__1591[] = {

static long ___L__50__eval_2El__1591[] = {
  "set"
,
    _acc = (oop)___L__50__eval_2El__1591;
  _tmp0 = _acc;
  _acc = _subr__set;
  _tmp2 = _acc;
  _acc = _define_2Dfsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__51__eval_2El__1592[] = {

static long ___L__52__eval_2El__1592[] = {
  "while"
,
    _acc = (oop)___L__52__eval_2El__1592;
  _tmp2 = _acc;
  _acc = _subr__while;
  _tmp0 = _acc;
  _acc = _define_2Dfsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__53__eval_2El__1593[] = {

static long ___L__54__eval_2El__1593[] = {
  "if"
,
    _acc = (oop)___L__54__eval_2El__1593;
  _tmp0 = _acc;
  _acc = _subr__if;
  _tmp2 = _acc;
  _acc = _define_2Dfsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__55__eval_2El__1594[] = {

static long ___L__56__eval_2El__1594[] = {
  "or"
,
    _acc = (oop)___L__56__eval_2El__1594;
  _tmp2 = _acc;
  _acc = _subr__or;
  _tmp0 = _acc;
  _acc = _define_2Dfsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__57__eval_2El__1595[] = {

static long ___L__58__eval_2El__1595[] = {
  "and"
,
    _acc = (oop)___L__58__eval_2El__1595;
  _tmp0 = _acc;
  _acc = _subr__and;
  _tmp2 = _acc;
  _acc = _define_2Dfsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__59__eval_2El__1596[] = {

static long ___L__60__eval_2El__1596[] = {
  "quote"
,
    _acc = (oop)___L__60__eval_2El__1596;
  _tmp2 = _acc;
  _acc = _subr__quote;
  _tmp0 = _acc;
  _acc = _define_2Dfsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__61__eval_2El__1597[] = {

static long ___L__62__eval_2El__1597[] = {
  "defined?"
,
    _acc = (oop)___L__62__eval_2El__1597;
  _tmp0 = _acc;
  _acc = _subr__definedP;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__63__eval_2El__1598[] = {

static long ___L__64__eval_2El__1598[] = {
  "not"
,
    _acc = (oop)___L__64__eval_2El__1598;
  _tmp2 = _acc;
  _acc = _subr__not;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__65__eval_2El__1599[] = {

static long ___L__66__eval_2El__1599[] = {
  "&"
,
    _acc = (oop)___L__66__eval_2El__1599;
  _tmp0 = _acc;
  _acc = _subr__bitand;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__67__eval_2El__1600[] = {

static long ___L__68__eval_2El__1600[] = {
  "|"
,
    _acc = (oop)___L__68__eval_2El__1600;
  _tmp2 = _acc;
  _acc = _subr__bitor;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__69__eval_2El__1601[] = {

static long ___L__70__eval_2El__1601[] = {
  "^"
,
    _acc = (oop)___L__70__eval_2El__1601;
  _tmp0 = _acc;
  _acc = _subr__bitxor;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__71__eval_2El__1602[] = {

static long ___L__72__eval_2El__1602[] = {
  "+"
,
    _acc = (oop)___L__72__eval_2El__1602;
  _tmp2 = _acc;
  _acc = _subr__add;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__73__eval_2El__1603[] = {

static long ___L__74__eval_2El__1603[] = {
  "-"
,
    _acc = (oop)___L__74__eval_2El__1603;
  _tmp0 = _acc;
  _acc = _subr__sub;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__75__eval_2El__1604[] = {

static long ___L__76__eval_2El__1604[] = {
  "*"
,
    _acc = (oop)___L__76__eval_2El__1604;
  _tmp2 = _acc;
  _acc = _subr__mul;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__77__eval_2El__1605[] = {

static long ___L__78__eval_2El__1605[] = {
  "/"
,
    _acc = (oop)___L__78__eval_2El__1605;
  _tmp0 = _acc;
  _acc = _subr__div;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__79__eval_2El__1606[] = {

static long ___L__80__eval_2El__1606[] = {
  "<<"
,
    _acc = (oop)___L__80__eval_2El__1606;
  _tmp2 = _acc;
  _acc = _subr__shl;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__81__eval_2El__1607[] = {

static long ___L__82__eval_2El__1607[] = {
  ">>"
,
    _acc = (oop)___L__82__eval_2El__1607;
  _tmp0 = _acc;
  _acc = _subr__shr;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__83__eval_2El__1608[] = {

static long ___L__84__eval_2El__1608[] = {
  "<"
,
    _acc = (oop)___L__84__eval_2El__1608;
  _tmp2 = _acc;
  _acc = _subr__lt;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__85__eval_2El__1609[] = {

static long ___L__86__eval_2El__1609[] = {
  "<="
,
    _acc = (oop)___L__86__eval_2El__1609;
  _tmp0 = _acc;
  _acc = _subr__le;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__87__eval_2El__1610[] = {

static long ___L__88__eval_2El__1610[] = {
  "!="
,
    _acc = (oop)___L__88__eval_2El__1610;
  _tmp2 = _acc;
  _acc = _subr__ne;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__89__eval_2El__1611[] = {

static long ___L__90__eval_2El__1611[] = {
  "="
,
    _acc = (oop)___L__90__eval_2El__1611;
  _tmp0 = _acc;
  _acc = _subr__eq;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__91__eval_2El__1612[] = {

static long ___L__92__eval_2El__1612[] = {
  ">="
,
    _acc = (oop)___L__92__eval_2El__1612;
  _tmp2 = _acc;
  _acc = _subr__ge;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__93__eval_2El__1613[] = {

static long ___L__94__eval_2El__1613[] = {
  ">"
,
    _acc = (oop)___L__94__eval_2El__1613;
  _tmp0 = _acc;
  _acc = _subr__gt;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__95__eval_2El__1614[] = {

static long ___L__96__eval_2El__1614[] = {
  "abort"
,
    _acc = (oop)___L__96__eval_2El__1614;
  _tmp2 = _acc;
  _acc = _subr__abort;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__97__eval_2El__1615[] = {

static long ___L__98__eval_2El__1615[] = {
  "exit"
,
    _acc = (oop)___L__98__eval_2El__1615;
  _tmp0 = _acc;
  _acc = _subr__exit;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__99__eval_2El__1616[] = {

static long ___L__100__eval_2El__1616[] = {
  "format"
,
    _acc = (oop)___L__100__eval_2El__1616;
  _tmp2 = _acc;
  _acc = _subr__format;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__101__eval_2El__1617[] = {

static long ___L__102__eval_2El__1617[] = {
  "dump"
,
    _acc = (oop)___L__102__eval_2El__1617;
  _tmp0 = _acc;
  _acc = _subr__dump;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__103__eval_2El__1618[] = {

static long ___L__104__eval_2El__1618[] = {
  "print"
,
    _acc = (oop)___L__104__eval_2El__1618;
  _tmp2 = _acc;
  _acc = _subr__print;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__105__eval_2El__1619[] = {

static long ___L__106__eval_2El__1619[] = {
  "warn"
,
    _acc = (oop)___L__106__eval_2El__1619;
  _tmp0 = _acc;
  _acc = _subr__warn;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__107__eval_2El__1620[] = {

static long ___L__108__eval_2El__1620[] = {
  "apply"
,
    _acc = (oop)___L__108__eval_2El__1620;
  _tmp2 = _acc;
  _acc = _subr__apply;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__109__eval_2El__1621[] = {

static long ___L__110__eval_2El__1621[] = {
  "eval"
,
    _acc = (oop)___L__110__eval_2El__1621;
  _tmp0 = _acc;
  _acc = _subr__eval;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__111__eval_2El__1622[] = {

static long ___L__112__eval_2El__1622[] = {
  "encode"
,
    _acc = (oop)___L__112__eval_2El__1622;
  _tmp2 = _acc;
  _acc = _subr__encode;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__113__eval_2El__1623[] = {

static long ___L__114__eval_2El__1623[] = {
  "expand"
,
    _acc = (oop)___L__114__eval_2El__1623;
  _tmp0 = _acc;
  _acc = _subr__expand;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__115__eval_2El__1624[] = {

static long ___L__116__eval_2El__1624[] = {
  "cons"
,
    _acc = (oop)___L__116__eval_2El__1624;
  _tmp2 = _acc;
  _acc = _subr__cons;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__117__eval_2El__1625[] = {

static long ___L__118__eval_2El__1625[] = {
  "string"
,
    _acc = (oop)___L__118__eval_2El__1625;
  _tmp0 = _acc;
  _acc = _subr__string;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__119__eval_2El__1626[] = {

static long ___L__120__eval_2El__1626[] = {
  "array"
,
    _acc = (oop)___L__120__eval_2El__1626;
  _tmp2 = _acc;
  _acc = _subr__array;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__121__eval_2El__1627[] = {

static long ___L__122__eval_2El__1627[] = {
  "form"
,
    _acc = (oop)___L__122__eval_2El__1627;
  _tmp0 = _acc;
  _acc = _subr__form;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__123__eval_2El__1628[] = {

static long ___L__124__eval_2El__1628[] = {
  "open"
,
    _acc = (oop)___L__124__eval_2El__1628;
  _tmp2 = _acc;
  _acc = _subr__open;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__125__eval_2El__1629[] = {

static long ___L__126__eval_2El__1629[] = {
  "close"
,
    _acc = (oop)___L__126__eval_2El__1629;
  _tmp0 = _acc;
  _acc = _subr__close;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__127__eval_2El__1630[] = {

static long ___L__128__eval_2El__1630[] = {
  "getc"
,
    _acc = (oop)___L__128__eval_2El__1630;
  _tmp2 = _acc;
  _acc = _subr__getc;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__129__eval_2El__1631[] = {

static long ___L__130__eval_2El__1631[] = {
  "putc"
,
    _acc = (oop)___L__130__eval_2El__1631;
  _tmp0 = _acc;
  _acc = _subr__putc;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__131__eval_2El__1632[] = {

static long ___L__132__eval_2El__1632[] = {
  "allocate"
,
    _acc = (oop)___L__132__eval_2El__1632;
  _tmp2 = _acc;
  _acc = _subr__allocate;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__133__eval_2El__1633[] = {

static long ___L__134__eval_2El__1633[] = {
  "type-of"
,
    _acc = (oop)___L__134__eval_2El__1633;
  _tmp0 = _acc;
  _acc = _subr__type__of;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__135__eval_2El__1634[] = {

static long ___L__136__eval_2El__1634[] = {
  "string?"
,
    _acc = (oop)___L__136__eval_2El__1634;
  _tmp2 = _acc;
  _acc = _subr__stringP;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__137__eval_2El__1635[] = {

static long ___L__138__eval_2El__1635[] = {
  "symbol?"
,
    _acc = (oop)___L__138__eval_2El__1635;
  _tmp0 = _acc;
  _acc = _subr__symbolP;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__139__eval_2El__1636[] = {

static long ___L__140__eval_2El__1636[] = {
  "pair?"
,
    _acc = (oop)___L__140__eval_2El__1636;
  _tmp2 = _acc;
  _acc = _subr__pairP;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__141__eval_2El__1637[] = {

static long ___L__142__eval_2El__1637[] = {
  "array?"
,
    _acc = (oop)___L__142__eval_2El__1637;
  _tmp0 = _acc;
  _acc = _subr__arrayP;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__143__eval_2El__1638[] = {

static long ___L__144__eval_2El__1638[] = {
  "car"
,
    _acc = (oop)___L__144__eval_2El__1638;
  _tmp2 = _acc;
  _acc = _subr__car;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__145__eval_2El__1639[] = {

static long ___L__146__eval_2El__1639[] = {
  "cdr"
,
    _acc = (oop)___L__146__eval_2El__1639;
  _tmp0 = _acc;
  _acc = _subr__cdr;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__147__eval_2El__1640[] = {

static long ___L__148__eval_2El__1640[] = {
  "set-car"
,
    _acc = (oop)___L__148__eval_2El__1640;
  _tmp2 = _acc;
  _acc = _subr__set__car;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__149__eval_2El__1641[] = {

static long ___L__150__eval_2El__1641[] = {
  "set-cdr"
,
    _acc = (oop)___L__150__eval_2El__1641;
  _tmp0 = _acc;
  _acc = _subr__set__cdr;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__151__eval_2El__1642[] = {

static long ___L__152__eval_2El__1642[] = {
  "oop-at"
,
    _acc = (oop)___L__152__eval_2El__1642;
  _tmp2 = _acc;
  _acc = _subr__oop__at;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__153__eval_2El__1643[] = {

static long ___L__154__eval_2El__1643[] = {
  "set-oop-at"
,
    _acc = (oop)___L__154__eval_2El__1643;
  _tmp0 = _acc;
  _acc = _subr__set__oop__at;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__155__eval_2El__1644[] = {

static long ___L__156__eval_2El__1644[] = {
  "array-length"
,
    _acc = (oop)___L__156__eval_2El__1644;
  _tmp2 = _acc;
  _acc = _subr__array__length;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__157__eval_2El__1645[] = {

static long ___L__158__eval_2El__1645[] = {
  "array-at"
,
    _acc = (oop)___L__158__eval_2El__1645;
  _tmp0 = _acc;
  _acc = _subr__array__at;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__159__eval_2El__1646[] = {

static long ___L__160__eval_2El__1646[] = {
  "set-array-at"
,
    _acc = (oop)___L__160__eval_2El__1646;
  _tmp2 = _acc;
  _acc = _subr__set__array__at;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__161__eval_2El__1647[] = {

static long ___L__162__eval_2El__1647[] = {
  "string-length"
,
    _acc = (oop)___L__162__eval_2El__1647;
  _tmp0 = _acc;
  _acc = _subr__string__length;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__163__eval_2El__1648[] = {

static long ___L__164__eval_2El__1648[] = {
  "string-at"
,
    _acc = (oop)___L__164__eval_2El__1648;
  _tmp2 = _acc;
  _acc = _subr__string__at;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__165__eval_2El__1649[] = {

static long ___L__166__eval_2El__1649[] = {
  "set-string-at"
,
    _acc = (oop)___L__166__eval_2El__1649;
  _tmp0 = _acc;
  _acc = _subr__set__string__at;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__167__eval_2El__1650[] = {

static long ___L__168__eval_2El__1650[] = {
  "string->symbol"
,
    _acc = (oop)___L__168__eval_2El__1650;
  _tmp2 = _acc;
  _acc = _subr__string__symbol;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__169__eval_2El__1651[] = {

static long ___L__170__eval_2El__1651[] = {
  "symbol->string"
,
    _acc = (oop)___L__170__eval_2El__1651;
  _tmp0 = _acc;
  _acc = _subr__symbol__string;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__171__eval_2El__1652[] = {

static long ___L__172__eval_2El__1652[] = {
  "long->string"
,
    _acc = (oop)___L__172__eval_2El__1652;
  _tmp2 = _acc;
  _acc = _subr__long__string;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__173__eval_2El__1653[] = {

static long ___L__174__eval_2El__1653[] = {
  "verbose"
,
    _acc = (oop)___L__174__eval_2El__1653;
  _tmp0 = _acc;
  _acc = _subr__verbose;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__175__eval_2El__1654[] = {

static long ___L__176__eval_2El__1654[] = {
  "optimised"
,
    _acc = (oop)___L__176__eval_2El__1654;
  _tmp2 = _acc;
  _acc = _subr__optimised;
  _tmp0 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp2;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__177__eval_2El__1655[] = {

static long ___L__178__eval_2El__1655[] = {
  "read"
,
    _acc = (oop)___L__178__eval_2El__1655;
  _tmp0 = _acc;
  _acc = _subr__read;
  _tmp2 = _acc;
  _acc = _define_2Dsubr;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__179__eval_2El__1657[] = {
  _acc = LONG(0);
  _tmp2 = _acc;

static long ___L__180__eval_2El__1658[] = {
  _acc = (oop)&_tmp2;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__181__eval_2El__1659[] = {
  goto ___L__183__eval_2El__1659;

static long ___L__182__eval_2El__1659[] = {

static long ___L__184__eval_2El__1660[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp0;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__185__eval_2El__1661[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp3 = _acc;
  _acc = _new_2D_3Cstring_3E;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp3 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp2;
  ((oop*)_acc)[getLong(_tmp0)] = _tmp3;

static long ___L__183__eval_2El__1659[] = {

static long ___L__186__eval_2El__1659[] = {
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) - getLong(_tmp3));
  _tmp0 = _acc;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = (getLong(_acc) < getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__182__eval_2El__1659;

static long ___L__187__eval_2El__1662[] = {
  _acc = _globals;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = __3Cvariable_3E;
  _tmp1 = _acc;
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp3 = _acc;

static long ___L__188__eval_2El__1662[] = {
  "*arguments*"
,
    _acc = (oop)___L__188__eval_2El__1662;
  _tmp0 = _acc;
  _acc = _intern;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp3;
  _tmp1 = _tmp0;
  _tmp2 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _arguments = _acc;
  _tmp4 = _acc;

static long ___L__189__eval_2El__1658[] = {
  _acc = (oop)&_tmp2;
  _tmp0 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp4;

static long ___L__190__eval_2El__1664[] = {
  _acc = _globals;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cvariable_3E;
  _tmp0 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp0;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp2 = _acc;
  _acc = _s__set;
  _tmp4 = _acc;
  _acc = _k__env__lookup;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _f__set = _acc;
  _acc = (oop)&_f__set;
  _tmp4 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__191__eval_2El__1665[] = {
  _acc = _globals;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp4;
  _tmp0 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp4 = _acc;
  _acc = _s__quote;
  _tmp2 = _acc;
  _acc = _k__env__lookup;
  _tmp0 = _tmp4;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _f__quote = _acc;
  _acc = (oop)&_f__quote;
  _tmp2 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__192__eval_2El__1666[] = {
  _acc = _globals;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cvariable_3E;
  _tmp0 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp0;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp2 = _acc;
  _acc = _s__lambda;
  _tmp4 = _acc;
  _acc = _k__env__lookup;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _f__lambda = _acc;
  _acc = (oop)&_f__lambda;
  _tmp4 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__193__eval_2El__1667[] = {
  _acc = _globals;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp4;
  _tmp0 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp4 = _acc;
  _acc = _s__let;
  _tmp2 = _acc;
  _acc = _k__env__lookup;
  _tmp0 = _tmp4;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _f__let = _acc;
  _acc = (oop)&_f__let;
  _tmp2 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__194__eval_2El__1668[] = {
  _acc = _globals;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cvariable_3E;
  _tmp0 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp0;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp2 = _acc;
  _acc = _s__define;
  _tmp4 = _acc;
  _acc = _k__env__lookup;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _f__define = _acc;
  _acc = (oop)&_f__define;
  _tmp4 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__195__eval_2El__1670[] = {
  _acc = LONG(32);
  _tmp4 = _acc;
  _acc = _new_2D_3Carray_3E;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _trace__stack = _acc;
  _acc = (oop)&_trace__stack;
  _tmp4 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__196__eval_2El__1672[] = {
  _acc = _globals;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp4;
  _tmp0 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp4 = _acc;

static long ___L__197__eval_2El__1672[] = {
  "*backtrace*"
,
    _acc = (oop)___L__197__eval_2El__1672;
  _tmp2 = _acc;
  _acc = _intern;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp4;
  _tmp1 = _tmp2;
  _tmp2 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__198__eval_2El__1674[] = {
  goto ___L__200__eval_2El__1674;

static long ___L__199__eval_2El__1674[] = {

static long ___L__201__eval_2El__1675[] = {
  _acc = _arguments;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp0 = _acc;

static long ___L__202__eval_2El__1676[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;

static long ___L__203__eval_2El__1675[] = {

static long ___L__204__eval_2El__1677[] = {
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cstring_3E;
  _tmp1 = _acc;
  _acc = _tmp3;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp3 = _acc;

static long ___L__205__eval_2El__1678[] = {
  _acc = (oop)&_tmp2;
  _tmp4 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__206__eval_2El__1679[] = {
  _acc = _arguments;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp5 = _acc;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = __3Cvariable_3E;
  _tmp6 = _acc;
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp1)] = _tmp5;

static long ___L__207__eval_2El__1680[] = {

static long ___L__210__eval_2El__1681[] = {
  _acc = _tmp3;
  _tmp4 = _acc;

static long ___L__211__eval_2El__1681[] = {
  "-v"
,
    _acc = (oop)___L__211__eval_2El__1681;
  _tmp5 = _acc;
  _acc = _strcmp_24stub;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = (_acc == nil) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__208__eval_2El__1680;
  _acc = _opt__verbose;
  _tmp5 = _acc;
  _acc = LONG(1);
  _acc = LONG(getLong(_acc) + getLong(_tmp5));
  _opt__verbose = _acc;
  goto ___L__209__eval_2El__1680;

static long ___L__208__eval_2El__1680[] = {

static long ___L__212__eval_2El__1680[] = {

static long ___L__215__eval_2El__1682[] = {
  _acc = _tmp3;
  _tmp5 = _acc;

static long ___L__216__eval_2El__1682[] = {
  "-O"
,
    _acc = (oop)___L__216__eval_2El__1682;
  _tmp4 = _acc;
  _acc = _strcmp_24stub;
  _tmp0 = _tmp5;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = (_acc == nil) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__213__eval_2El__1680;
  _acc = _opt__optimised;
  _tmp4 = _acc;
  _acc = LONG(1);
  _acc = LONG(getLong(_acc) + getLong(_tmp4));
  _opt__optimised = _acc;
  goto ___L__214__eval_2El__1680;

static long ___L__213__eval_2El__1680[] = {

static long ___L__217__eval_2El__1680[] = {

static long ___L__220__eval_2El__1683[] = {
  _acc = _tmp3;
  _tmp4 = _acc;

static long ___L__221__eval_2El__1683[] = {
  "-"
,
    _acc = (oop)___L__221__eval_2El__1683;
  _tmp5 = _acc;
  _acc = _strcmp_24stub;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = (_acc == nil) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__218__eval_2El__1680;
  _acc = _stdin;
  _tmp5 = _acc;
  _acc = _repl__stream;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__219__eval_2El__1680;

static long ___L__218__eval_2El__1680[] = {

static long ___L__222__eval_2El__1684[] = {
  _acc = _tmp3;
  _tmp5 = _acc;

static long ___L__223__eval_2El__1684[] = {
  "r"
,
    _acc = (oop)___L__223__eval_2El__1684;
  _tmp4 = _acc;
  _acc = _fopen_24stub;
  _tmp0 = _tmp5;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp4 = _acc;

static long ___L__224__eval_2El__1685[] = {
  _acc = _tmp4;
  if (_acc != nil) goto ___L__225__eval_2El__1685;

static long ___L__226__eval_2El__1685[] = {
  "no such file: %s"
,
    _acc = (oop)___L__226__eval_2El__1685;
  _tmp5 = _acc;
  _acc = _tmp3;
  _tmp1 = _acc;
  _acc = _fatal1;
  _tmp0 = _tmp5;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__225__eval_2El__1685[] = {

static long ___L__227__eval_2El__1686[] = {
  _acc = _tmp4;
  _tmp1 = _acc;
  _acc = _repl__stream;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__228__eval_2El__1687[] = {
  _acc = _tmp4;
  _tmp1 = _acc;
  _acc = _fclose_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__219__eval_2El__1680[] = {

static long ___L__214__eval_2El__1680[] = {

static long ___L__209__eval_2El__1680[] = {
  _tmp4 = _acc;

static long ___L__229__eval_2El__1678[] = {
  _acc = (oop)&_tmp2;
  _tmp1 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp4;

static long ___L__200__eval_2El__1674[] = {

static long ___L__230__eval_2El__1674[] = {
  _acc = _arguments;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__231__eval_2El__1674;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__233__eval_2El__1674;
  _acc = __3Clong_3E;
  goto ___L__234__eval_2El__1674;

static long ___L__233__eval_2El__1674[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__234__eval_2El__1674[] = {
  goto ___L__232__eval_2El__1674;

static long ___L__231__eval_2El__1674[] = {
  _acc = __3Cundefined_3E;

static long ___L__232__eval_2El__1674[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__199__eval_2El__1674;

static long ___L__235__eval_2El__1689[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _opt__verbose;
  _acc = (getLong(_acc) > getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__236__eval_2El__1689;

static long ___L__237__eval_2El__1690[] = {

static long ___L__238__eval_2El__1691[] = {
  _acc = _gc__gcollect;
  _acc = ((oop (*)())_acc)();

static long ___L__239__eval_2El__1692[] = {

static long ___L__240__eval_2El__1692[] = {
  "GC: %d objects in %d bytes, %d free\012"
,
    _acc = (oop)___L__240__eval_2El__1692;
  _tmp0 = _acc;
  _acc = _gc__objects__live;
  _tmp2 = _acc;
  _acc = _gc__bytes__used;
  _tmp4 = _acc;
  _acc = _gc__bytes__free;
  _tmp3 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _tmp2 = _tmp4;
  _tmp3 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2, _arg3);

static long ___L__236__eval_2El__1689[] = {

static long ___L__241__eval_2El__1694[] = {
  _acc = _stderr;
  _tmp3 = _acc;

static long ___L__242__eval_2El__1694[] = {
  "%d objects in %d bytes, %d free\012"
,
    _acc = (oop)___L__242__eval_2El__1694;
  _tmp4 = _acc;
  _acc = _gc__objects__live;
  _tmp2 = _acc;
  _acc = _gc__bytes__used;
  _tmp0 = _acc;
  _acc = _gc__bytes__free;
  _tmp1 = _acc;
  _acc = _fprintf_24stub;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _tmp2 = _tmp2;
  _tmp3 = _tmp0;
  _tmp4 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2, _arg3, _arg4);
  _acc = LONG(0);
return 0;
}

## defn define-fsubr
oop define-fsubr(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__243__eval_2El__1552[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _new_2D_3Csubr_3E;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__244__eval_2El__1553[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__245__eval_2El__1554[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _new_2D_3Cfixed_3E;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__246__eval_2El__1555[] = {
  _acc = _globals;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _intern;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _tmp2 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp4 = _acc;

static long ___L__247__eval_2El__1553[] = {
  _acc = (oop)&_tmp1;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp4;
return _acc;
}

oop define-fsubr = (oop)define-fsubr;
## defn define-subr
oop define-subr(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__248__eval_2El__1547[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _new_2D_3Csubr_3E;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__249__eval_2El__1548[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__250__eval_2El__1549[] = {
  _acc = _globals;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _intern;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _tmp2 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp4 = _acc;

static long ___L__251__eval_2El__1548[] = {
  _acc = (oop)&_tmp1;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp4;
return _acc;
}

oop define-subr = (oop)define-subr;
## defn repl_stream
oop repl_stream(oop _param0) {
  oop _acc = nil;

static long ___L__252__eval_2El__1524[] = {
  _acc = _input;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp1;

static long ___L__253__eval_2El__1525[] = {
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__254__eval_2El__1526[] = {
  _acc = (oop)&_tmp0;
  _tmp1 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__255__eval_2El__1527[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _stdin;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__256__eval_2El__1527;
  _acc = _tmp0;
  _tmp1 = _acc;

static long ___L__257__eval_2El__1527[] = {
  "#!%*[^\012\015]"
,
    _acc = (oop)___L__257__eval_2El__1527;
  _tmp2 = _acc;
  _acc = _fscanf_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__256__eval_2El__1527[] = {

static long ___L__258__eval_2El__1528[] = {
  goto ___L__260__eval_2El__1528;

static long ___L__259__eval_2El__1528[] = {

static long ___L__261__eval_2El__1531[] = {
  _acc = _globals;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = __3Cvariable_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp2 = _acc;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = _new_2D_3Cenv_3E;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp3 = _acc;

static long ___L__262__eval_2El__1532[] = {
  _acc = (oop)&_tmp3;
  _tmp1 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__263__eval_2El__1533[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _opt__verbose;
  _acc = (getLong(_acc) > getLong(_tmp1)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__264__eval_2El__1533;

static long ___L__265__eval_2El__1533[] = {
  ";;; "
,
    _acc = (oop)___L__265__eval_2El__1533;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__264__eval_2El__1533;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__dumpln;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__264__eval_2El__1533[] = {

static long ___L__266__eval_2El__1534[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp3;
  _tmp2 = _acc;
  _acc = _k__expand;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = _opt__verbose;
  _acc = (getLong(_acc) > getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__267__eval_2El__1534;

static long ___L__268__eval_2El__1534[] = {
  "expd--> "
,
    _acc = (oop)___L__268__eval_2El__1534;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__267__eval_2El__1534;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__dumpln;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__267__eval_2El__1534[] = {

static long ___L__269__eval_2El__1535[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp3;
  _tmp1 = _acc;
  _acc = _k__encode;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  _acc = LONG(2);
  _tmp1 = _acc;
  _acc = _opt__verbose;
  _acc = (getLong(_acc) > getLong(_tmp1)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__270__eval_2El__1535;

static long ___L__271__eval_2El__1535[] = {
  "encd--> "
,
    _acc = (oop)___L__271__eval_2El__1535;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__270__eval_2El__1535;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__dumpln;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__270__eval_2El__1535[] = {

static long ___L__272__eval_2El__1536[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = _new_2Dbase_2D_3Ccontext_3E;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _tmp2 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp4 = _acc;

static long ___L__273__eval_2El__1537[] = {
  _acc = (oop)&_tmp4;
  _tmp2 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__274__eval_2El__1538[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp4;
  _tmp1 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _opt__verbose;
  _acc = (getLong(_acc) > getLong(_tmp1)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__275__eval_2El__1538;

static long ___L__276__eval_2El__1538[] = {
  "eval--> "
,
    _acc = (oop)___L__276__eval_2El__1538;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__275__eval_2El__1538;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__dumpln;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__275__eval_2El__1538[] = {

static long ___L__277__eval_2El__1539[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _stdin;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__278__eval_2El__1539;

static long ___L__280__eval_2El__1540[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__dumpln;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__279__eval_2El__1539;

static long ___L__278__eval_2El__1539[] = {

static long ___L__281__eval_2El__1541[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _opt__verbose;
  _acc = (getLong(_acc) > getLong(_tmp1)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__282__eval_2El__1541;

static long ___L__283__eval_2El__1541[] = {
  ";;; => "
,
    _acc = (oop)___L__283__eval_2El__1541;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__282__eval_2El__1541;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__dumpln;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__282__eval_2El__1541[] = {

static long ___L__279__eval_2El__1539[] = {
  _tmp1 = _acc;

static long ___L__284__eval_2El__1537[] = {
  _acc = (oop)&_tmp4;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp4 = _acc;

static long ___L__285__eval_2El__1532[] = {
  _acc = (oop)&_tmp3;
  _tmp1 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp4;

static long ___L__260__eval_2El__1528[] = {

static long ___L__286__eval_2El__1528[] = {

static long ___L__287__eval_2El__1529[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _stdin;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__288__eval_2El__1529;
  _acc = _stdout;
  _tmp3 = _acc;

static long ___L__289__eval_2El__1529[] = {
  "."
,
    _acc = (oop)___L__289__eval_2El__1529;
  _tmp4 = _acc;
  _acc = _fprintf_24stub;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  if (_acc == nil) goto ___L__288__eval_2El__1529;
  _acc = _stdout;
  _tmp4 = _acc;
  _acc = _fflush_24stub;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__288__eval_2El__1529[] = {

static long ___L__290__eval_2El__1530[] = {
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = _k__read;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _tmp4 = _acc;
  _acc = _DONE;
  _acc = (_acc != _tmp4) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__259__eval_2El__1528;

static long ___L__291__eval_2El__1542[] = {
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = _stdin;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__292__eval_2El__1542;

static long ___L__293__eval_2El__1543[] = {

static long ___L__294__eval_2El__1543[] = {
  "\012morituri te salutant\012"
,
    _acc = (oop)___L__294__eval_2El__1543;
  _tmp4 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__292__eval_2El__1542[] = {
  _tmp4 = _acc;

static long ___L__295__eval_2El__1526[] = {
  _acc = (oop)&_tmp0;
  _tmp3 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp4;
  _acc = _tmp0;
return _acc;
}

oop repl_stream = (oop)repl_stream;
## defn subr_read
oop subr_read(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__296__eval_2El__1502[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__297__eval_2El__1502;

static long ___L__299__eval_2El__1503[] = {
  _acc = _stdin;
  _tmp0 = _acc;
  _acc = _k__read;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__300__eval_2El__1504[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _DONE;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__301__eval_2El__1504;
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__301__eval_2El__1504[] = {
  _acc = _tmp0;
  goto ___L__298__eval_2El__1502;

static long ___L__297__eval_2El__1502[] = {

static long ___L__302__eval_2El__1506[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__303__eval_2El__1507[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__305__eval_2El__1507;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__307__eval_2El__1507;
  _acc = __3Clong_3E;
  goto ___L__308__eval_2El__1507;

static long ___L__307__eval_2El__1507[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__308__eval_2El__1507[] = {
  goto ___L__306__eval_2El__1507;

static long ___L__305__eval_2El__1507[] = {
  _acc = __3Cundefined_3E;

static long ___L__306__eval_2El__1507[] = {
  _tmp1 = _acc;
  _acc = __3Cstring_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__304__eval_2El__1507;

static long ___L__309__eval_2El__1507[] = {
  "read: non-String argument: "
,
    _acc = (oop)___L__309__eval_2El__1507;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _fatal1;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__304__eval_2El__1507[] = {

static long ___L__310__eval_2El__1508[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = __3Cstring_3E;
  _tmp3 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp2 = _acc;

static long ___L__311__eval_2El__1509[] = {
  _acc = _tmp2;
  _tmp1 = _acc;

static long ___L__312__eval_2El__1509[] = {
  "r"
,
    _acc = (oop)___L__312__eval_2El__1509;
  _tmp4 = _acc;
  _acc = _fopen_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp4 = _acc;

static long ___L__313__eval_2El__1510[] = {
  _acc = _tmp4;
  if (_acc == nil) goto ___L__314__eval_2El__1510;

static long ___L__316__eval_2El__1511[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp1;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp3 = _acc;
  _acc = _tmp3;
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp5 = _acc;

static long ___L__317__eval_2El__1514[] = {
  _acc = (oop)&_tmp3;
  _tmp6 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = (oop)&_tmp5;
  _tmp6 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__318__eval_2El__1515[] = {
  goto ___L__320__eval_2El__1515;

static long ___L__319__eval_2El__1515[] = {

static long ___L__321__eval_2El__1516[] = {
  _acc = _tmp5;
  _tmp6 = _acc;
  _acc = LONG(0);
  _tmp7 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp7 = _acc;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp1;
  ((oop*)_acc)[getLong(_tmp6)] = _tmp7;
  _tmp1 = _acc;

static long ___L__320__eval_2El__1515[] = {

static long ___L__322__eval_2El__1515[] = {
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = _k__read;
  _tmp0 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp5 = _acc;
  _tmp7 = _acc;
  _acc = _DONE;
  _acc = (_acc != _tmp7) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__319__eval_2El__1515;
  _tmp7 = _acc;

static long ___L__323__eval_2El__1514[] = {
  _acc = (oop)&_tmp5;
  _tmp6 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = (oop)&_tmp3;
  _tmp6 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp7;

static long ___L__324__eval_2El__1517[] = {
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = _fclose_24stub;
  _tmp0 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__325__eval_2El__1518[] = {
  _acc = LONG(1);
  _tmp7 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp7)];
  goto ___L__315__eval_2El__1510;

static long ___L__314__eval_2El__1510[] = {
  _acc = LONG(0);

static long ___L__315__eval_2El__1510[] = {

static long ___L__298__eval_2El__1502[] = {
return _acc;
}

oop subr_read = (oop)subr_read;
## defn subr_optimised
oop subr_optimised(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__326__eval_2El__1496[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__327__eval_2El__1497[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__330__eval_2El__1497;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__332__eval_2El__1497;
  _acc = __3Clong_3E;
  goto ___L__333__eval_2El__1497;

static long ___L__332__eval_2El__1497[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__333__eval_2El__1497[] = {
  goto ___L__331__eval_2El__1497;

static long ___L__330__eval_2El__1497[] = {
  _acc = __3Cundefined_3E;

static long ___L__331__eval_2El__1497[] = {
  _tmp1 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__328__eval_2El__1497;

static long ___L__334__eval_2El__1498[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _opt__optimised = _acc;
  goto ___L__329__eval_2El__1497;

static long ___L__328__eval_2El__1497[] = {

static long ___L__335__eval_2El__1499[] = {
  _acc = _opt__optimised;
  _tmp1 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__329__eval_2El__1497[] = {
return _acc;
}

oop subr_optimised = (oop)subr_optimised;
## defn subr_verbose
oop subr_verbose(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__336__eval_2El__1490[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__337__eval_2El__1491[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__340__eval_2El__1491;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__342__eval_2El__1491;
  _acc = __3Clong_3E;
  goto ___L__343__eval_2El__1491;

static long ___L__342__eval_2El__1491[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__343__eval_2El__1491[] = {
  goto ___L__341__eval_2El__1491;

static long ___L__340__eval_2El__1491[] = {
  _acc = __3Cundefined_3E;

static long ___L__341__eval_2El__1491[] = {
  _tmp1 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__338__eval_2El__1491;

static long ___L__344__eval_2El__1492[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _opt__verbose = _acc;
  goto ___L__339__eval_2El__1491;

static long ___L__338__eval_2El__1491[] = {

static long ___L__345__eval_2El__1493[] = {
  _acc = _opt__verbose;
  _tmp1 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__339__eval_2El__1491[] = {
return _acc;
}

oop subr_verbose = (oop)subr_verbose;
## defn subr_long_string
oop subr_long_string(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__346__eval_2El__1479[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__347__eval_2El__1480[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__350__eval_2El__1480;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__352__eval_2El__1480;
  _acc = __3Clong_3E;
  goto ___L__353__eval_2El__1480;

static long ___L__352__eval_2El__1480[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__353__eval_2El__1480[] = {
  goto ___L__351__eval_2El__1480;

static long ___L__350__eval_2El__1480[] = {
  _acc = __3Cundefined_3E;

static long ___L__351__eval_2El__1480[] = {
  _tmp1 = _acc;
  _acc = __3Cstring_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__348__eval_2El__1480;
  _acc = _tmp0;
  goto ___L__349__eval_2El__1480;

static long ___L__348__eval_2El__1480[] = {

static long ___L__354__eval_2El__1482[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__356__eval_2El__1482;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__358__eval_2El__1482;
  _acc = __3Clong_3E;
  goto ___L__359__eval_2El__1482;

static long ___L__358__eval_2El__1482[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__359__eval_2El__1482[] = {
  goto ___L__357__eval_2El__1482;

static long ___L__356__eval_2El__1482[] = {
  _acc = __3Cundefined_3E;

static long ___L__357__eval_2El__1482[] = {
  _tmp1 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__355__eval_2El__1482;

static long ___L__360__eval_2El__1483[] = {
  _acc = LONG(32);
  _tmp1 = _acc;
  _acc = _malloc_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__361__eval_2El__1484[] = {
  _acc = _tmp1;
  _tmp2 = _acc;

static long ___L__362__eval_2El__1484[] = {
  "%ld"
,
    _acc = (oop)___L__362__eval_2El__1484;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp6 = _acc;
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp4 = _acc;
  _acc = _sprintf_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _tmp2 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__363__eval_2El__1485[] = {
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _new_2D_3Cstring_3E;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp4 = _acc;

static long ___L__364__eval_2El__1486[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _free_24stub;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp4;

static long ___L__355__eval_2El__1482[] = {

static long ___L__349__eval_2El__1480[] = {
return _acc;
}

oop subr_long_string = (oop)subr_long_string;
## defn subr_symbol_string
oop subr_symbol_string(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__365__eval_2El__1472[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__366__eval_2El__1473[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__369__eval_2El__1473;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__371__eval_2El__1473;
  _acc = __3Clong_3E;
  goto ___L__372__eval_2El__1473;

static long ___L__371__eval_2El__1473[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__372__eval_2El__1473[] = {
  goto ___L__370__eval_2El__1473;

static long ___L__369__eval_2El__1473[] = {
  _acc = __3Cundefined_3E;

static long ___L__370__eval_2El__1473[] = {
  _tmp1 = _acc;
  _acc = __3Cstring_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__367__eval_2El__1473;
  _acc = _tmp0;
  goto ___L__368__eval_2El__1473;

static long ___L__367__eval_2El__1473[] = {

static long ___L__373__eval_2El__1475[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__375__eval_2El__1475;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__377__eval_2El__1475;
  _acc = __3Clong_3E;
  goto ___L__378__eval_2El__1475;

static long ___L__377__eval_2El__1475[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__378__eval_2El__1475[] = {
  goto ___L__376__eval_2El__1475;

static long ___L__375__eval_2El__1475[] = {
  _acc = __3Cundefined_3E;

static long ___L__376__eval_2El__1475[] = {
  _tmp1 = _acc;
  _acc = __3Csymbol_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__374__eval_2El__1475;

static long ___L__379__eval_2El__1476[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Csymbol_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp1 = _acc;
  _acc = _new_2D_3Cstring_3E;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__374__eval_2El__1475[] = {

static long ___L__368__eval_2El__1473[] = {
return _acc;
}

oop subr_symbol_string = (oop)subr_symbol_string;
## defn subr_string_symbol
oop subr_string_symbol(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__380__eval_2El__1465[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__381__eval_2El__1466[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__384__eval_2El__1466;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__386__eval_2El__1466;
  _acc = __3Clong_3E;
  goto ___L__387__eval_2El__1466;

static long ___L__386__eval_2El__1466[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__387__eval_2El__1466[] = {
  goto ___L__385__eval_2El__1466;

static long ___L__384__eval_2El__1466[] = {
  _acc = __3Cundefined_3E;

static long ___L__385__eval_2El__1466[] = {
  _tmp1 = _acc;
  _acc = __3Csymbol_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__382__eval_2El__1466;
  _acc = _tmp0;
  goto ___L__383__eval_2El__1466;

static long ___L__382__eval_2El__1466[] = {

static long ___L__388__eval_2El__1468[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__390__eval_2El__1468;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__392__eval_2El__1468;
  _acc = __3Clong_3E;
  goto ___L__393__eval_2El__1468;

static long ___L__392__eval_2El__1468[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__393__eval_2El__1468[] = {
  goto ___L__391__eval_2El__1468;

static long ___L__390__eval_2El__1468[] = {
  _acc = __3Cundefined_3E;

static long ___L__391__eval_2El__1468[] = {
  _tmp1 = _acc;
  _acc = __3Cstring_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__389__eval_2El__1468;

static long ___L__394__eval_2El__1469[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cstring_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp1 = _acc;
  _acc = _intern;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__389__eval_2El__1468[] = {

static long ___L__383__eval_2El__1466[] = {
return _acc;
}

oop subr_string_symbol = (oop)subr_string_symbol;
## defn subr_set_string_at
oop subr_set_string_at(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__395__eval_2El__1453[] = {

static long ___L__396__eval_2El__1453[] = {
  "set-string-at"
,
    _acc = (oop)___L__396__eval_2El__1453;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity3;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__397__eval_2El__1454[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;

static long ___L__398__eval_2El__1455[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__399__eval_2El__1456[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;

static long ___L__400__eval_2El__1457[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__402__eval_2El__1457;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp4));
  if (_acc == nil) goto ___L__404__eval_2El__1457;
  _acc = __3Clong_3E;
  goto ___L__405__eval_2El__1457;

static long ___L__404__eval_2El__1457[] = {
  _acc = LONG(-1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp4)];

static long ___L__405__eval_2El__1457[] = {
  goto ___L__403__eval_2El__1457;

static long ___L__402__eval_2El__1457[] = {
  _acc = __3Cundefined_3E;

static long ___L__403__eval_2El__1457[] = {
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__401__eval_2El__1457;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__406__eval_2El__1457;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp4));
  if (_acc == nil) goto ___L__408__eval_2El__1457;
  _acc = __3Clong_3E;
  goto ___L__409__eval_2El__1457;

static long ___L__408__eval_2El__1457[] = {
  _acc = LONG(-1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp4)];

static long ___L__409__eval_2El__1457[] = {
  goto ___L__407__eval_2El__1457;

static long ___L__406__eval_2El__1457[] = {
  _acc = __3Cundefined_3E;

static long ___L__407__eval_2El__1457[] = {
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__401__eval_2El__1457;

static long ___L__410__eval_2El__1458[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = __3Clong_3E;
  _tmp5 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp3 = _acc;

static long ___L__411__eval_2El__1459[] = {
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = (getLong(_acc) <= getLong(_tmp4)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__412__eval_2El__1459;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _k__string__length;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = (getLong(_acc) < getLong(_tmp4)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__412__eval_2El__1459;

static long ___L__413__eval_2El__1460[] = {

static long ___L__414__eval_2El__1461[] = {
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Clong_3E;
  _tmp5 = _acc;
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = _tmp1;
  _tmp7 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = __3Cstring_3E;
  _tmp8 = _acc;
  _acc = _tmp7;
  _tmp9 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp8;
  _tmp1 = _tmp9;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  ((char*)_acc)[getLong(_tmp6)] = (char)getLong(_tmp4);
  _acc = _tmp2;

static long ___L__412__eval_2El__1459[] = {

static long ___L__401__eval_2El__1457[] = {
return _acc;
}

oop subr_set_string_at = (oop)subr_set_string_at;
## defn subr_string_at
oop subr_string_at(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__415__eval_2El__1444[] = {

static long ___L__416__eval_2El__1444[] = {
  "string-at"
,
    _acc = (oop)___L__416__eval_2El__1444;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__417__eval_2El__1445[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;

static long ___L__418__eval_2El__1446[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__419__eval_2El__1447[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__421__eval_2El__1447;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__423__eval_2El__1447;
  _acc = __3Clong_3E;
  goto ___L__424__eval_2El__1447;

static long ___L__423__eval_2El__1447[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__424__eval_2El__1447[] = {
  goto ___L__422__eval_2El__1447;

static long ___L__421__eval_2El__1447[] = {
  _acc = __3Cundefined_3E;

static long ___L__422__eval_2El__1447[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__420__eval_2El__1447;

static long ___L__425__eval_2El__1448[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;

static long ___L__426__eval_2El__1449[] = {
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = (getLong(_acc) <= getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__427__eval_2El__1449;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _k__string__length;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = (getLong(_acc) < getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__427__eval_2El__1449;

static long ___L__428__eval_2El__1450[] = {
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cstring_3E;
  _tmp6 = _acc;
  _acc = _tmp5;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _acc = LONG(((char*)_acc)[getLong(_tmp3)]);
  _tmp3 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__427__eval_2El__1449[] = {

static long ___L__420__eval_2El__1447[] = {
return _acc;
}

oop subr_string_at = (oop)subr_string_at;
## defn subr_string_length
oop subr_string_length(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__429__eval_2El__1439[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__430__eval_2El__1440[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__432__eval_2El__1440;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__434__eval_2El__1440;
  _acc = __3Clong_3E;
  goto ___L__435__eval_2El__1440;

static long ___L__434__eval_2El__1440[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__435__eval_2El__1440[] = {
  goto ___L__433__eval_2El__1440;

static long ___L__432__eval_2El__1440[] = {
  _acc = __3Cundefined_3E;

static long ___L__433__eval_2El__1440[] = {
  _tmp1 = _acc;
  _acc = __3Cstring_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__431__eval_2El__1440;

static long ___L__436__eval_2El__1441[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cstring_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__431__eval_2El__1440[] = {
return _acc;
}

oop subr_string_length = (oop)subr_string_length;
## defn subr_set_array_at
oop subr_set_array_at(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__437__eval_2El__1431[] = {

static long ___L__438__eval_2El__1431[] = {
  "set-array-at"
,
    _acc = (oop)___L__438__eval_2El__1431;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity3;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__439__eval_2El__1432[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;

static long ___L__440__eval_2El__1433[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__441__eval_2El__1434[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;

static long ___L__442__eval_2El__1435[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__444__eval_2El__1435;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp4));
  if (_acc == nil) goto ___L__446__eval_2El__1435;
  _acc = __3Clong_3E;
  goto ___L__447__eval_2El__1435;

static long ___L__446__eval_2El__1435[] = {
  _acc = LONG(-1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp4)];

static long ___L__447__eval_2El__1435[] = {
  goto ___L__445__eval_2El__1435;

static long ___L__444__eval_2El__1435[] = {
  _acc = __3Cundefined_3E;

static long ___L__445__eval_2El__1435[] = {
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__443__eval_2El__1435;

static long ___L__448__eval_2El__1436[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp6 = _acc;
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = _k__set__array__at;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__443__eval_2El__1435[] = {
return _acc;
}

oop subr_set_array_at = (oop)subr_set_array_at;
## defn subr_array_at
oop subr_array_at(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__449__eval_2El__1424[] = {

static long ___L__450__eval_2El__1424[] = {
  "array-at"
,
    _acc = (oop)___L__450__eval_2El__1424;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__451__eval_2El__1425[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;

static long ___L__452__eval_2El__1426[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__453__eval_2El__1427[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__455__eval_2El__1427;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__457__eval_2El__1427;
  _acc = __3Clong_3E;
  goto ___L__458__eval_2El__1427;

static long ___L__457__eval_2El__1427[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__458__eval_2El__1427[] = {
  goto ___L__456__eval_2El__1427;

static long ___L__455__eval_2El__1427[] = {
  _acc = __3Cundefined_3E;

static long ___L__456__eval_2El__1427[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__454__eval_2El__1427;

static long ___L__459__eval_2El__1428[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = __3Clong_3E;
  _tmp5 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp3 = _acc;
  _acc = _k__array__at;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__454__eval_2El__1427[] = {
return _acc;
}

oop subr_array_at = (oop)subr_array_at;
## defn subr_array_length
oop subr_array_length(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__460__eval_2El__1421[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _k__array__length;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop subr_array_length = (oop)subr_array_length;
## defn subr_set_oop_at
oop subr_set_oop_at(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__461__eval_2El__1411[] = {

static long ___L__462__eval_2El__1411[] = {
  "set-oop-at"
,
    _acc = (oop)___L__462__eval_2El__1411;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity3;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__463__eval_2El__1412[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;

static long ___L__464__eval_2El__1413[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__465__eval_2El__1414[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;

static long ___L__466__eval_2El__1415[] = {
  _acc = _tmp1;
  if (_acc == nil) goto ___L__467__eval_2El__1415;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__468__eval_2El__1415;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp4));
  if (_acc == nil) goto ___L__470__eval_2El__1415;
  _acc = __3Clong_3E;
  goto ___L__471__eval_2El__1415;

static long ___L__470__eval_2El__1415[] = {
  _acc = LONG(-1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp4)];

static long ___L__471__eval_2El__1415[] = {
  goto ___L__469__eval_2El__1415;

static long ___L__468__eval_2El__1415[] = {
  _acc = __3Cundefined_3E;

static long ___L__469__eval_2El__1415[] = {
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  _acc = (_acc == nil) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__467__eval_2El__1415;

static long ___L__472__eval_2El__1416[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__473__eval_2El__1416;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp4));
  if (_acc == nil) goto ___L__475__eval_2El__1416;
  _acc = __3Clong_3E;
  goto ___L__476__eval_2El__1416;

static long ___L__475__eval_2El__1416[] = {
  _acc = LONG(-1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp4)];

static long ___L__476__eval_2El__1416[] = {
  goto ___L__474__eval_2El__1416;

static long ___L__473__eval_2El__1416[] = {
  _acc = __3Cundefined_3E;

static long ___L__474__eval_2El__1416[] = {
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__467__eval_2El__1415;

static long ___L__477__eval_2El__1417[] = {
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp6 = _acc;
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp4 = _acc;
  _acc = _tmp1;
  ((oop*)_acc)[getLong(_tmp4)] = _tmp3;

static long ___L__467__eval_2El__1415[] = {
  _acc = _tmp2;
return _acc;
}

oop subr_set_oop_at = (oop)subr_set_oop_at;
## defn subr_oop_at
oop subr_oop_at(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__478__eval_2El__1403[] = {

static long ___L__479__eval_2El__1403[] = {
  "oop-at"
,
    _acc = (oop)___L__479__eval_2El__1403;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__480__eval_2El__1404[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;

static long ___L__481__eval_2El__1405[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__482__eval_2El__1406[] = {
  _acc = _tmp1;
  if (_acc == nil) goto ___L__483__eval_2El__1406;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__484__eval_2El__1406;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__486__eval_2El__1406;
  _acc = __3Clong_3E;
  goto ___L__487__eval_2El__1406;

static long ___L__486__eval_2El__1406[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__487__eval_2El__1406[] = {
  goto ___L__485__eval_2El__1406;

static long ___L__484__eval_2El__1406[] = {
  _acc = __3Cundefined_3E;

static long ___L__485__eval_2El__1406[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  _acc = (_acc == nil) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__483__eval_2El__1406;

static long ___L__488__eval_2El__1407[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__489__eval_2El__1407;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__491__eval_2El__1407;
  _acc = __3Clong_3E;
  goto ___L__492__eval_2El__1407;

static long ___L__491__eval_2El__1407[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__492__eval_2El__1407[] = {
  goto ___L__490__eval_2El__1407;

static long ___L__489__eval_2El__1407[] = {
  _acc = __3Cundefined_3E;

static long ___L__490__eval_2El__1407[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__483__eval_2El__1406;

static long ___L__493__eval_2El__1408[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__483__eval_2El__1406[] = {
return _acc;
}

oop subr_oop_at = (oop)subr_oop_at;
## defn subr_set_cdr
oop subr_set_cdr(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__494__eval_2El__1398[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__495__eval_2El__1399[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__497__eval_2El__1399;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__499__eval_2El__1399;
  _acc = __3Clong_3E;
  goto ___L__500__eval_2El__1399;

static long ___L__499__eval_2El__1399[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__500__eval_2El__1399[] = {
  goto ___L__498__eval_2El__1399;

static long ___L__497__eval_2El__1399[] = {
  _acc = __3Cundefined_3E;

static long ___L__498__eval_2El__1399[] = {
  _tmp1 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__496__eval_2El__1399;

static long ___L__501__eval_2El__1400[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = __3Cpair_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp3)] = _tmp2;

static long ___L__496__eval_2El__1399[] = {
return _acc;
}

oop subr_set_cdr = (oop)subr_set_cdr;
## defn subr_set_car
oop subr_set_car(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__502__eval_2El__1393[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__503__eval_2El__1394[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__505__eval_2El__1394;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__507__eval_2El__1394;
  _acc = __3Clong_3E;
  goto ___L__508__eval_2El__1394;

static long ___L__507__eval_2El__1394[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__508__eval_2El__1394[] = {
  goto ___L__506__eval_2El__1394;

static long ___L__505__eval_2El__1394[] = {
  _acc = __3Cundefined_3E;

static long ___L__506__eval_2El__1394[] = {
  _tmp1 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__504__eval_2El__1394;

static long ___L__509__eval_2El__1395[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Cpair_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp3)] = _tmp2;

static long ___L__504__eval_2El__1394[] = {
return _acc;
}

oop subr_set_car = (oop)subr_set_car;
## defn subr_cdr
oop subr_cdr(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__510__eval_2El__1390[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _k__cdr;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop subr_cdr = (oop)subr_cdr;
## defn subr_car
oop subr_car(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__511__eval_2El__1389[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop subr_car = (oop)subr_car;
## defn subr_arrayP
oop subr_arrayP(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__512__eval_2El__1388[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__514__eval_2El__1388;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__516__eval_2El__1388;
  _acc = __3Clong_3E;
  goto ___L__517__eval_2El__1388;

static long ___L__516__eval_2El__1388[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__517__eval_2El__1388[] = {
  goto ___L__515__eval_2El__1388;

static long ___L__514__eval_2El__1388[] = {
  _acc = __3Cundefined_3E;

static long ___L__515__eval_2El__1388[] = {
  _tmp0 = _acc;
  _acc = __3Carray_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__513__eval_2El__1388;
  _acc = _s__t;

static long ___L__513__eval_2El__1388[] = {
return _acc;
}

oop subr_arrayP = (oop)subr_arrayP;
## defn subr_pairP
oop subr_pairP(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__518__eval_2El__1387[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__520__eval_2El__1387;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__522__eval_2El__1387;
  _acc = __3Clong_3E;
  goto ___L__523__eval_2El__1387;

static long ___L__522__eval_2El__1387[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__523__eval_2El__1387[] = {
  goto ___L__521__eval_2El__1387;

static long ___L__520__eval_2El__1387[] = {
  _acc = __3Cundefined_3E;

static long ___L__521__eval_2El__1387[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__519__eval_2El__1387;
  _acc = _s__t;

static long ___L__519__eval_2El__1387[] = {
return _acc;
}

oop subr_pairP = (oop)subr_pairP;
## defn subr_symbolP
oop subr_symbolP(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__524__eval_2El__1386[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__526__eval_2El__1386;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__528__eval_2El__1386;
  _acc = __3Clong_3E;
  goto ___L__529__eval_2El__1386;

static long ___L__528__eval_2El__1386[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__529__eval_2El__1386[] = {
  goto ___L__527__eval_2El__1386;

static long ___L__526__eval_2El__1386[] = {
  _acc = __3Cundefined_3E;

static long ___L__527__eval_2El__1386[] = {
  _tmp0 = _acc;
  _acc = __3Csymbol_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__525__eval_2El__1386;
  _acc = _s__t;

static long ___L__525__eval_2El__1386[] = {
return _acc;
}

oop subr_symbolP = (oop)subr_symbolP;
## defn subr_stringP
oop subr_stringP(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__530__eval_2El__1385[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__532__eval_2El__1385;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__534__eval_2El__1385;
  _acc = __3Clong_3E;
  goto ___L__535__eval_2El__1385;

static long ___L__534__eval_2El__1385[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__535__eval_2El__1385[] = {
  goto ___L__533__eval_2El__1385;

static long ___L__532__eval_2El__1385[] = {
  _acc = __3Cundefined_3E;

static long ___L__533__eval_2El__1385[] = {
  _tmp0 = _acc;
  _acc = __3Cstring_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__531__eval_2El__1385;
  _acc = _s__t;

static long ___L__531__eval_2El__1385[] = {
return _acc;
}

oop subr_stringP = (oop)subr_stringP;
## defn subr_type_of
oop subr_type_of(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__536__eval_2El__1384[] = {
  _acc = _tmp0;
  if (_acc == nil) goto ___L__537__eval_2El__1384;
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__538__eval_2El__1384;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__540__eval_2El__1384;
  _acc = __3Clong_3E;
  goto ___L__541__eval_2El__1384;

static long ___L__540__eval_2El__1384[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__541__eval_2El__1384[] = {
  goto ___L__539__eval_2El__1384;

static long ___L__538__eval_2El__1384[] = {
  _acc = __3Cundefined_3E;

static long ___L__539__eval_2El__1384[] = {
  _tmp0 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__537__eval_2El__1384[] = {
return _acc;
}

oop subr_type_of = (oop)subr_type_of;
## defn subr_allocate
oop subr_allocate(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__542__eval_2El__1378[] = {

static long ___L__543__eval_2El__1378[] = {
  "allocate"
,
    _acc = (oop)___L__543__eval_2El__1378;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__544__eval_2El__1379[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;

static long ___L__545__eval_2El__1380[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__546__eval_2El__1381[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__548__eval_2El__1381;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__550__eval_2El__1381;
  _acc = __3Clong_3E;
  goto ___L__551__eval_2El__1381;

static long ___L__550__eval_2El__1381[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__551__eval_2El__1381[] = {
  goto ___L__549__eval_2El__1381;

static long ___L__548__eval_2El__1381[] = {
  _acc = __3Cundefined_3E;

static long ___L__549__eval_2El__1381[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__547__eval_2El__1381;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__552__eval_2El__1381;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__554__eval_2El__1381;
  _acc = __3Clong_3E;
  goto ___L__555__eval_2El__1381;

static long ___L__554__eval_2El__1381[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__555__eval_2El__1381[] = {
  goto ___L__553__eval_2El__1381;

static long ___L__552__eval_2El__1381[] = {
  _acc = __3Cundefined_3E;

static long ___L__553__eval_2El__1381[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__547__eval_2El__1381;

static long ___L__556__eval_2El__1382[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = LONG(4);
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = __3Clong_3E;
  _tmp6 = _acc;
  _acc = _tmp5;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _acc = LONG(getLong(_acc) * getLong(_tmp3));
  _tmp3 = _acc;
  _acc = _new_2Doops;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__547__eval_2El__1381[] = {
return _acc;
}

oop subr_allocate = (oop)subr_allocate;
## defn subr_form
oop subr_form(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__557__eval_2El__1375[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = _new_2D_3Cform_3E;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
return _acc;
}

oop subr_form = (oop)subr_form;
## defn subr_array
oop subr_array(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__558__eval_2El__1374[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__560__eval_2El__1374;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__562__eval_2El__1374;
  _acc = __3Clong_3E;
  goto ___L__563__eval_2El__1374;

static long ___L__562__eval_2El__1374[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__563__eval_2El__1374[] = {
  goto ___L__561__eval_2El__1374;

static long ___L__560__eval_2El__1374[] = {
  _acc = __3Cundefined_3E;

static long ___L__561__eval_2El__1374[] = {
  _tmp0 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__559__eval_2El__1374;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Clong_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__559__eval_2El__1374[] = {
  _tmp0 = _acc;
  _acc = _new_2D_3Carray_3E;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop subr_array = (oop)subr_array;
## defn subr_string
oop subr_string(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__564__eval_2El__1373[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__566__eval_2El__1373;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__568__eval_2El__1373;
  _acc = __3Clong_3E;
  goto ___L__569__eval_2El__1373;

static long ___L__568__eval_2El__1373[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__569__eval_2El__1373[] = {
  goto ___L__567__eval_2El__1373;

static long ___L__566__eval_2El__1373[] = {
  _acc = __3Cundefined_3E;

static long ___L__567__eval_2El__1373[] = {
  _tmp0 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__565__eval_2El__1373;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Clong_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__565__eval_2El__1373[] = {
  _tmp0 = _acc;
  _acc = ___new_2D_3Cstring_3E;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop subr_string = (oop)subr_string;
## defn subr_cons
oop subr_cons(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__570__eval_2El__1372[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
return _acc;
}

oop subr_cons = (oop)subr_cons;
## defn subr_expand
oop subr_expand(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__571__eval_2El__1368[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__572__eval_2El__1369[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc != nil) goto ___L__573__eval_2El__1369;

static long ___L__574__eval_2El__1370[] = {
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Ccontext_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__573__eval_2El__1369[] = {
  _tmp1 = _acc;
  _acc = _k__expand;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
return _acc;
}

oop subr_expand = (oop)subr_expand;
## defn subr_encode
oop subr_encode(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__575__eval_2El__1363[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__576__eval_2El__1364[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc != nil) goto ___L__577__eval_2El__1364;

static long ___L__578__eval_2El__1365[] = {
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Ccontext_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__577__eval_2El__1364[] = {
  _tmp1 = _acc;
  _acc = _k__encode;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
return _acc;
}

oop subr_encode = (oop)subr_encode;
## defn subr_eval
oop subr_eval(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__579__eval_2El__1353[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__580__eval_2El__1354[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc != nil) goto ___L__581__eval_2El__1354;
  _acc = _globals;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp1 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = _new_2D_3Cenv_3E;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _tmp2 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__581__eval_2El__1354[] = {
  _tmp4 = _acc;

static long ___L__582__eval_2El__1355[] = {
  _acc = (oop)&_tmp0;
  _tmp2 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = (oop)&_tmp4;
  _tmp2 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__583__eval_2El__1356[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp4;
  _tmp3 = _acc;
  _acc = _new_2Dbase_2D_3Ccontext_3E;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp3 = _acc;

static long ___L__584__eval_2El__1357[] = {
  _acc = (oop)&_tmp3;
  _tmp1 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__585__eval_2El__1358[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp4;
  _tmp2 = _acc;
  _acc = _k__expand;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__586__eval_2El__1359[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp4;
  _tmp1 = _acc;
  _acc = _k__encode;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__587__eval_2El__1360[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp3;
  _tmp2 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__588__eval_2El__1357[] = {
  _acc = (oop)&_tmp3;
  _tmp1 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp2;
  _tmp3 = _acc;

static long ___L__589__eval_2El__1355[] = {
  _acc = (oop)&_tmp4;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = (oop)&_tmp0;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp3;
return _acc;
}

oop subr_eval = (oop)subr_eval;
## defn subr_apply
oop subr_apply(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__590__eval_2El__1350[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__apply;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _tmp2 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
return _acc;
}

oop subr_apply = (oop)subr_apply;
## defn subr_warn
oop subr_warn(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__591__eval_2El__1341[] = {
  goto ___L__593__eval_2El__1341;

static long ___L__592__eval_2El__1341[] = {

static long ___L__594__eval_2El__1342[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__595__eval_2El__1343[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__596__eval_2El__1343;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__598__eval_2El__1343;
  _acc = __3Clong_3E;
  goto ___L__599__eval_2El__1343;

static long ___L__598__eval_2El__1343[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__599__eval_2El__1343[] = {
  goto ___L__597__eval_2El__1343;

static long ___L__596__eval_2El__1343[] = {
  _acc = __3Cundefined_3E;

static long ___L__597__eval_2El__1343[] = {
  _tmp1 = _acc;

static long ___L__600__eval_2El__1344[] = {

static long ___L__603__eval_2El__1345[] = {
  _acc = __3Cstring_3E;
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__601__eval_2El__1344;
  _acc = _stderr;
  _tmp2 = _acc;

static long ___L__604__eval_2El__1345[] = {
  "%s"
,
    _acc = (oop)___L__604__eval_2El__1345;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = __3Cstring_3E;
  _tmp6 = _acc;
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp4 = _acc;
  _acc = _fprintf_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _tmp2 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  goto ___L__602__eval_2El__1344;

static long ___L__601__eval_2El__1344[] = {

static long ___L__605__eval_2El__1344[] = {

static long ___L__608__eval_2El__1346[] = {
  _acc = __3Csymbol_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__606__eval_2El__1344;
  _acc = _stderr;
  _tmp4 = _acc;

static long ___L__609__eval_2El__1346[] = {
  "%s"
,
    _acc = (oop)___L__609__eval_2El__1346;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Csymbol_3E;
  _tmp7 = _acc;
  _acc = _tmp2;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp2 = _acc;
  _acc = _fprintf_24stub;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _tmp2 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  goto ___L__607__eval_2El__1344;

static long ___L__606__eval_2El__1344[] = {
  _acc = LONG(0);

static long ___L__607__eval_2El__1344[] = {

static long ___L__602__eval_2El__1344[] = {

static long ___L__610__eval_2El__1347[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__593__eval_2El__1341[] = {

static long ___L__611__eval_2El__1341[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__612__eval_2El__1341;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__614__eval_2El__1341;
  _acc = __3Clong_3E;
  goto ___L__615__eval_2El__1341;

static long ___L__614__eval_2El__1341[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__615__eval_2El__1341[] = {
  goto ___L__613__eval_2El__1341;

static long ___L__612__eval_2El__1341[] = {
  _acc = __3Cundefined_3E;

static long ___L__613__eval_2El__1341[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__592__eval_2El__1341;
return _acc;
}

oop subr_warn = (oop)subr_warn;
## defn subr_print
oop subr_print(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__616__eval_2El__1336[] = {
  goto ___L__618__eval_2El__1336;

static long ___L__617__eval_2El__1336[] = {

static long ___L__619__eval_2El__1337[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__620__eval_2El__1338[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__618__eval_2El__1336[] = {

static long ___L__621__eval_2El__1336[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__622__eval_2El__1336;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__624__eval_2El__1336;
  _acc = __3Clong_3E;
  goto ___L__625__eval_2El__1336;

static long ___L__624__eval_2El__1336[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__625__eval_2El__1336[] = {
  goto ___L__623__eval_2El__1336;

static long ___L__622__eval_2El__1336[] = {
  _acc = __3Cundefined_3E;

static long ___L__623__eval_2El__1336[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__617__eval_2El__1336;
return _acc;
}

oop subr_print = (oop)subr_print;
## defn subr_dump
oop subr_dump(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__626__eval_2El__1331[] = {
  goto ___L__628__eval_2El__1331;

static long ___L__627__eval_2El__1331[] = {

static long ___L__629__eval_2El__1332[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _k__dump;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__630__eval_2El__1333[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__628__eval_2El__1331[] = {

static long ___L__631__eval_2El__1331[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__632__eval_2El__1331;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__634__eval_2El__1331;
  _acc = __3Clong_3E;
  goto ___L__635__eval_2El__1331;

static long ___L__634__eval_2El__1331[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__635__eval_2El__1331[] = {
  goto ___L__633__eval_2El__1331;

static long ___L__632__eval_2El__1331[] = {
  _acc = __3Cundefined_3E;

static long ___L__633__eval_2El__1331[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__627__eval_2El__1331;
return _acc;
}

oop subr_dump = (oop)subr_dump;
## defn subr_format
oop subr_format(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__636__eval_2El__1302[] = {

static long ___L__637__eval_2El__1302[] = {
  "format"
,
    _acc = (oop)___L__637__eval_2El__1302;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__638__eval_2El__1303[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__639__eval_2El__1304[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__640__eval_2El__1305[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__642__eval_2El__1305;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__644__eval_2El__1305;
  _acc = __3Clong_3E;
  goto ___L__645__eval_2El__1305;

static long ___L__644__eval_2El__1305[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__645__eval_2El__1305[] = {
  goto ___L__643__eval_2El__1305;

static long ___L__642__eval_2El__1305[] = {
  _acc = __3Cundefined_3E;

static long ___L__643__eval_2El__1305[] = {
  _tmp2 = _acc;
  _acc = __3Cstring_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__641__eval_2El__1305;

static long ___L__646__eval_2El__1305[] = {
  "non-string format"
,
    _acc = (oop)___L__646__eval_2El__1305;
  _tmp2 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__641__eval_2El__1305[] = {

static long ___L__647__eval_2El__1306[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = __3Cstring_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;

static long ___L__648__eval_2El__1307[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__649__eval_2El__1307;
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp5));
  if (_acc == nil) goto ___L__651__eval_2El__1307;
  _acc = __3Clong_3E;
  goto ___L__652__eval_2El__1307;

static long ___L__651__eval_2El__1307[] = {
  _acc = LONG(-1);
  _tmp5 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp5)];

static long ___L__652__eval_2El__1307[] = {
  goto ___L__650__eval_2El__1307;

static long ___L__649__eval_2El__1307[] = {
  _acc = __3Cundefined_3E;

static long ___L__650__eval_2El__1307[] = {
  _tmp3 = _acc;
  _acc = LONG(0);
  _tmp5 = _acc;

static long ___L__653__eval_2El__1309[] = {

static long ___L__656__eval_2El__1310[] = {
  _acc = __3Cundefined_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__654__eval_2El__1309;
  _acc = LONG(0);
  goto ___L__655__eval_2El__1309;

static long ___L__654__eval_2El__1309[] = {

static long ___L__657__eval_2El__1309[] = {

static long ___L__660__eval_2El__1311[] = {
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__658__eval_2El__1309;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Clong_3E;
  _tmp7 = _acc;
  _acc = _tmp4;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp5 = _acc;
  goto ___L__659__eval_2El__1309;

static long ___L__658__eval_2El__1309[] = {

static long ___L__661__eval_2El__1309[] = {

static long ___L__664__eval_2El__1312[] = {
  _acc = __3Cstring_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__662__eval_2El__1309;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = __3Cstring_3E;
  _tmp8 = _acc;
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp8;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp5 = _acc;
  goto ___L__663__eval_2El__1309;

static long ___L__662__eval_2El__1309[] = {

static long ___L__665__eval_2El__1309[] = {

static long ___L__668__eval_2El__1313[] = {
  _acc = __3Csymbol_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__666__eval_2El__1309;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Csymbol_3E;
  _tmp7 = _acc;
  _acc = _tmp4;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp5 = _acc;
  goto ___L__667__eval_2El__1309;

static long ___L__666__eval_2El__1309[] = {

static long ___L__669__eval_2El__1314[] = {
  _acc = _tmp0;
  _tmp5 = _acc;

static long ___L__667__eval_2El__1309[] = {

static long ___L__663__eval_2El__1309[] = {

static long ___L__659__eval_2El__1309[] = {

static long ___L__655__eval_2El__1309[] = {

static long ___L__670__eval_2El__1315[] = {
  _acc = LONG(100);
  _tmp4 = _acc;
  _tmp6 = _acc;
  _tmp8 = _acc;

static long ___L__671__eval_2El__1316[] = {
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = _malloc_24stub;
  _tmp0 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp6 = _acc;

static long ___L__672__eval_2El__1316[] = {

static long ___L__673__eval_2El__1317[] = {
  goto ___L__675__eval_2El__1317;

static long ___L__674__eval_2El__1317[] = {

static long ___L__676__eval_2El__1318[] = {
  _acc = _tmp6;
  _tmp7 = _acc;
  _acc = _tmp4;
  _tmp9 = _acc;
  _acc = _tmp2;
  _tmp10 = _acc;
  _acc = _tmp5;
  _tmp11 = _acc;
  _acc = _snprintf_24stub;
  _tmp0 = _tmp7;
  _tmp1 = _tmp9;
  _tmp2 = _tmp10;
  _tmp3 = _tmp11;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2, _arg3);
  _tmp11 = _acc;

static long ___L__677__eval_2El__1319[] = {
  _acc = _tmp11;
  _tmp10 = _acc;
  _acc = LONG(0);
  _acc = (getLong(_acc) <= getLong(_tmp10)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__678__eval_2El__1319;
  _acc = _tmp4;
  _tmp10 = _acc;
  _acc = _tmp11;
  _acc = (getLong(_acc) < getLong(_tmp10)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__678__eval_2El__1319;

static long ___L__679__eval_2El__1320[] = {
  _acc = _tmp6;
  _tmp10 = _acc;
  _acc = _new_2D_3Cstring_3E;
  _tmp0 = _tmp10;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp10 = _acc;

static long ___L__680__eval_2El__1321[] = {
  _acc = _tmp6;
  _tmp9 = _acc;
  _acc = _free_24stub;
  _tmp0 = _tmp9;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__681__eval_2El__1322[] = {
  _acc = _tmp10;
  goto ___L__682__eval_2El__1322;

static long ___L__678__eval_2El__1319[] = {

static long ___L__683__eval_2El__1323[] = {
  _acc = LONG(2);
  _tmp10 = _acc;
  _acc = _tmp4;
  _acc = LONG(getLong(_acc) * getLong(_tmp10));
  _tmp4 = _acc;

static long ___L__684__eval_2El__1324[] = {
  _acc = _tmp6;
  _tmp11 = _acc;
  _acc = _tmp4;
  _tmp10 = _acc;
  _acc = _realloc_24stub;
  _tmp0 = _tmp11;
  _tmp1 = _tmp10;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp8 = _acc;
  if (_acc != nil) goto ___L__685__eval_2El__1324;

static long ___L__686__eval_2El__1325[] = {

static long ___L__687__eval_2El__1326[] = {
  _acc = _tmp6;
  _tmp10 = _acc;
  _acc = _free_24stub;
  _tmp0 = _tmp10;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__688__eval_2El__1327[] = {

static long ___L__689__eval_2El__1327[] = {
  "out of memory"
,
    _acc = (oop)___L__689__eval_2El__1327;
  goto ___L__682__eval_2El__1322;

static long ___L__685__eval_2El__1324[] = {

static long ___L__690__eval_2El__1328[] = {
  _acc = _tmp8;
  _tmp6 = _acc;

static long ___L__675__eval_2El__1317[] = {
  _acc = LONG(1);
  if (_acc != nil) goto ___L__674__eval_2El__1317;
___L__682__eval_2El__1322:
  return _acc;
}

oop subr_format = (oop)subr_format;
## defn subr_putc
oop subr_putc(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__691__eval_2El__1294[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__692__eval_2El__1295[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__693__eval_2El__1296[] = {
  _acc = _tmp0;
  if (_acc != nil) goto ___L__694__eval_2El__1296;
  _acc = _input;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = __3Cvariable_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp0 = _acc;

static long ___L__694__eval_2El__1296[] = {

static long ___L__695__eval_2El__1297[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__697__eval_2El__1297;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__699__eval_2El__1297;
  _acc = __3Clong_3E;
  goto ___L__700__eval_2El__1297;

static long ___L__699__eval_2El__1297[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__700__eval_2El__1297[] = {
  goto ___L__698__eval_2El__1297;

static long ___L__697__eval_2El__1297[] = {
  _acc = __3Cundefined_3E;

static long ___L__698__eval_2El__1297[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__696__eval_2El__1297;

static long ___L__701__eval_2El__1297[] = {
  "non-integer stream id in putc"
,
    _acc = (oop)___L__701__eval_2El__1297;
  _tmp2 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__696__eval_2El__1297[] = {

static long ___L__702__eval_2El__1298[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__704__eval_2El__1298;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__706__eval_2El__1298;
  _acc = __3Clong_3E;
  goto ___L__707__eval_2El__1298;

static long ___L__706__eval_2El__1298[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__707__eval_2El__1298[] = {
  goto ___L__705__eval_2El__1298;

static long ___L__704__eval_2El__1298[] = {
  _acc = __3Cundefined_3E;

static long ___L__705__eval_2El__1298[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__703__eval_2El__1298;

static long ___L__708__eval_2El__1298[] = {
  "non-integer character in putc"
,
    _acc = (oop)___L__708__eval_2El__1298;
  _tmp2 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__703__eval_2El__1298[] = {

static long ___L__709__eval_2El__1299[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _putc_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop subr_putc = (oop)subr_putc;
## defn subr_getc
oop subr_getc(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__710__eval_2El__1286[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__711__eval_2El__1287[] = {
  _acc = _tmp0;
  if (_acc != nil) goto ___L__712__eval_2El__1287;
  _acc = _input;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp0 = _acc;

static long ___L__712__eval_2El__1287[] = {

static long ___L__713__eval_2El__1288[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__715__eval_2El__1288;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__717__eval_2El__1288;
  _acc = __3Clong_3E;
  goto ___L__718__eval_2El__1288;

static long ___L__717__eval_2El__1288[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__718__eval_2El__1288[] = {
  goto ___L__716__eval_2El__1288;

static long ___L__715__eval_2El__1288[] = {
  _acc = __3Cundefined_3E;

static long ___L__716__eval_2El__1288[] = {
  _tmp1 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__714__eval_2El__1288;

static long ___L__719__eval_2El__1288[] = {
  "non-integer stream id in getc"
,
    _acc = (oop)___L__719__eval_2El__1288;
  _tmp1 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__714__eval_2El__1288[] = {

static long ___L__720__eval_2El__1289[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp1 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__721__eval_2El__1290[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = (getLong(_acc) >= getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__722__eval_2El__1290;

static long ___L__723__eval_2El__1291[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__722__eval_2El__1290[] = {
return _acc;
}

oop subr_getc = (oop)subr_getc;
## defn subr_close
oop subr_close(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__724__eval_2El__1280[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__725__eval_2El__1281[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__727__eval_2El__1281;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__729__eval_2El__1281;
  _acc = __3Clong_3E;
  goto ___L__730__eval_2El__1281;

static long ___L__729__eval_2El__1281[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__730__eval_2El__1281[] = {
  goto ___L__728__eval_2El__1281;

static long ___L__727__eval_2El__1281[] = {
  _acc = __3Cundefined_3E;

static long ___L__728__eval_2El__1281[] = {
  _tmp1 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__726__eval_2El__1281;

static long ___L__731__eval_2El__1281[] = {
  "non-integer argument in close"
,
    _acc = (oop)___L__731__eval_2El__1281;
  _tmp1 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__726__eval_2El__1281[] = {

static long ___L__732__eval_2El__1282[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp1 = _acc;
  _acc = _fclose_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
return _acc;
}

oop subr_close = (oop)subr_close;
## defn subr_open
oop subr_open(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__733__eval_2El__1274[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__734__eval_2El__1275[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__736__eval_2El__1275;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__738__eval_2El__1275;
  _acc = __3Clong_3E;
  goto ___L__739__eval_2El__1275;

static long ___L__738__eval_2El__1275[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__739__eval_2El__1275[] = {
  goto ___L__737__eval_2El__1275;

static long ___L__736__eval_2El__1275[] = {
  _acc = __3Cundefined_3E;

static long ___L__737__eval_2El__1275[] = {
  _tmp1 = _acc;
  _acc = __3Cstring_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__735__eval_2El__1275;

static long ___L__740__eval_2El__1275[] = {
  "non-string argument in open"
,
    _acc = (oop)___L__740__eval_2El__1275;
  _tmp1 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__735__eval_2El__1275[] = {

static long ___L__741__eval_2El__1276[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cstring_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp1 = _acc;

static long ___L__742__eval_2El__1276[] = {
  "rb"
,
    _acc = (oop)___L__742__eval_2El__1276;
  _tmp2 = _acc;
  _acc = _fopen_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__743__eval_2El__1277[] = {
  _acc = _tmp2;
  if (_acc == nil) goto ___L__744__eval_2El__1277;
  _acc = _tmp2;
  _tmp1 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__744__eval_2El__1277[] = {
return _acc;
}

oop subr_open = (oop)subr_open;
## defn subr_exit
oop subr_exit(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__745__eval_2El__1270[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__747__eval_2El__1270;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__749__eval_2El__1270;
  _acc = __3Clong_3E;
  goto ___L__750__eval_2El__1270;

static long ___L__749__eval_2El__1270[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__750__eval_2El__1270[] = {
  goto ___L__748__eval_2El__1270;

static long ___L__747__eval_2El__1270[] = {
  _acc = __3Cundefined_3E;

static long ___L__748__eval_2El__1270[] = {
  _tmp0 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__746__eval_2El__1270;
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Clong_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__746__eval_2El__1270[] = {
  _tmp0 = _acc;

static long ___L__751__eval_2El__1271[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _exit_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop subr_exit = (oop)subr_exit;
## defn subr_abort
oop subr_abort(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__752__eval_2El__1267[] = {
  _acc = _abort_24stub;
  _acc = ((oop (*)())_acc)();
return _acc;
}

oop subr_abort = (oop)subr_abort;
## defn subr_ne
oop subr_ne(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__753__eval_2El__1257[] = {

static long ___L__754__eval_2El__1257[] = {
  "!="
,
    _acc = (oop)___L__754__eval_2El__1257;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__755__eval_2El__1258[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;

static long ___L__756__eval_2El__1259[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__757__eval_2El__1258[] = {

static long ___L__758__eval_2El__1260[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__759__eval_2El__1260;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__761__eval_2El__1260;
  _acc = __3Clong_3E;
  goto ___L__762__eval_2El__1260;

static long ___L__761__eval_2El__1260[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__762__eval_2El__1260[] = {
  goto ___L__760__eval_2El__1260;

static long ___L__759__eval_2El__1260[] = {
  _acc = __3Cundefined_3E;

static long ___L__760__eval_2El__1260[] = {
  _tmp2 = _acc;

static long ___L__763__eval_2El__1261[] = {

static long ___L__766__eval_2El__1262[] = {
  _acc = __3Clong_3E;
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__764__eval_2El__1261;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__768__eval_2El__1262;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp4));
  if (_acc == nil) goto ___L__770__eval_2El__1262;
  _acc = __3Clong_3E;
  goto ___L__771__eval_2El__1262;

static long ___L__770__eval_2El__1262[] = {
  _acc = LONG(-1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp4)];

static long ___L__771__eval_2El__1262[] = {
  goto ___L__769__eval_2El__1262;

static long ___L__768__eval_2El__1262[] = {
  _acc = __3Cundefined_3E;

static long ___L__769__eval_2El__1262[] = {
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__767__eval_2El__1262;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = __3Clong_3E;
  _tmp5 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Clong_3E;
  _tmp5 = _acc;
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _acc = (_acc != _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__767__eval_2El__1262;
  _acc = _s__t;

static long ___L__767__eval_2El__1262[] = {
  goto ___L__765__eval_2El__1261;

static long ___L__764__eval_2El__1261[] = {

static long ___L__772__eval_2El__1261[] = {

static long ___L__775__eval_2El__1263[] = {
  _acc = __3Cstring_3E;
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__773__eval_2El__1261;

static long ___L__776__eval_2El__1261[] = {

static long ___L__777__eval_2El__1263[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__779__eval_2El__1263;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp4));
  if (_acc == nil) goto ___L__781__eval_2El__1263;
  _acc = __3Clong_3E;
  goto ___L__782__eval_2El__1263;

static long ___L__781__eval_2El__1263[] = {
  _acc = LONG(-1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp4)];

static long ___L__782__eval_2El__1263[] = {
  goto ___L__780__eval_2El__1263;

static long ___L__779__eval_2El__1263[] = {
  _acc = __3Cundefined_3E;

static long ___L__780__eval_2El__1263[] = {
  _tmp3 = _acc;
  _acc = __3Cstring_3E;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__778__eval_2El__1263;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cstring_3E;
  _tmp6 = _acc;
  _acc = _tmp3;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp7 = _acc;
  _acc = __3Cstring_3E;
  _tmp6 = _acc;
  _acc = _tmp4;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp7)];
  _tmp4 = _acc;
  _acc = _strcmp_24stub;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__778__eval_2El__1263[] = {
  _acc = _s__t;
  goto ___L__774__eval_2El__1261;

static long ___L__773__eval_2El__1261[] = {

static long ___L__783__eval_2El__1264[] = {
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = _tmp1;
  _acc = (_acc != _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__784__eval_2El__1264;
  _acc = _s__t;

static long ___L__784__eval_2El__1264[] = {

static long ___L__774__eval_2El__1261[] = {

static long ___L__765__eval_2El__1261[] = {
return _acc;
}

oop subr_ne = (oop)subr_ne;
## defn subr_eq
oop subr_eq(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__785__eval_2El__1247[] = {

static long ___L__786__eval_2El__1247[] = {
  "="
,
    _acc = (oop)___L__786__eval_2El__1247;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__787__eval_2El__1248[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;

static long ___L__788__eval_2El__1249[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__789__eval_2El__1248[] = {

static long ___L__790__eval_2El__1250[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__791__eval_2El__1250;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__793__eval_2El__1250;
  _acc = __3Clong_3E;
  goto ___L__794__eval_2El__1250;

static long ___L__793__eval_2El__1250[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__794__eval_2El__1250[] = {
  goto ___L__792__eval_2El__1250;

static long ___L__791__eval_2El__1250[] = {
  _acc = __3Cundefined_3E;

static long ___L__792__eval_2El__1250[] = {
  _tmp2 = _acc;

static long ___L__795__eval_2El__1251[] = {

static long ___L__798__eval_2El__1252[] = {
  _acc = __3Clong_3E;
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__796__eval_2El__1251;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__800__eval_2El__1252;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp4));
  if (_acc == nil) goto ___L__802__eval_2El__1252;
  _acc = __3Clong_3E;
  goto ___L__803__eval_2El__1252;

static long ___L__802__eval_2El__1252[] = {
  _acc = LONG(-1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp4)];

static long ___L__803__eval_2El__1252[] = {
  goto ___L__801__eval_2El__1252;

static long ___L__800__eval_2El__1252[] = {
  _acc = __3Cundefined_3E;

static long ___L__801__eval_2El__1252[] = {
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__799__eval_2El__1252;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = __3Clong_3E;
  _tmp5 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Clong_3E;
  _tmp5 = _acc;
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__799__eval_2El__1252;
  _acc = _s__t;

static long ___L__799__eval_2El__1252[] = {
  goto ___L__797__eval_2El__1251;

static long ___L__796__eval_2El__1251[] = {

static long ___L__804__eval_2El__1251[] = {

static long ___L__807__eval_2El__1253[] = {
  _acc = __3Cstring_3E;
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__805__eval_2El__1251;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__809__eval_2El__1253;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp4));
  if (_acc == nil) goto ___L__811__eval_2El__1253;
  _acc = __3Clong_3E;
  goto ___L__812__eval_2El__1253;

static long ___L__811__eval_2El__1253[] = {
  _acc = LONG(-1);
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp4)];

static long ___L__812__eval_2El__1253[] = {
  goto ___L__810__eval_2El__1253;

static long ___L__809__eval_2El__1253[] = {
  _acc = __3Cundefined_3E;

static long ___L__810__eval_2El__1253[] = {
  _tmp3 = _acc;
  _acc = __3Cstring_3E;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__808__eval_2El__1253;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cstring_3E;
  _tmp6 = _acc;
  _acc = _tmp3;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp7 = _acc;
  _acc = __3Cstring_3E;
  _tmp6 = _acc;
  _acc = _tmp4;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp7)];
  _tmp4 = _acc;
  _acc = _strcmp_24stub;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = (_acc == nil) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__808__eval_2El__1253;
  _acc = _s__t;

static long ___L__808__eval_2El__1253[] = {
  goto ___L__806__eval_2El__1251;

static long ___L__805__eval_2El__1251[] = {

static long ___L__813__eval_2El__1254[] = {
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = _tmp1;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__814__eval_2El__1254;
  _acc = _s__t;

static long ___L__814__eval_2El__1254[] = {

static long ___L__806__eval_2El__1251[] = {

static long ___L__797__eval_2El__1251[] = {
return _acc;
}

oop subr_eq = (oop)subr_eq;
## defn subr_gt
oop subr_gt(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__815__eval_2El__1244[] = {

static long ___L__816__eval_2El__1244[] = {
  "gt"
,
    _acc = (oop)___L__816__eval_2El__1244;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__820__eval_2El__1244;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__822__eval_2El__1244;
  _acc = __3Clong_3E;
  goto ___L__823__eval_2El__1244;

static long ___L__822__eval_2El__1244[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__823__eval_2El__1244[] = {
  goto ___L__821__eval_2El__1244;

static long ___L__820__eval_2El__1244[] = {
  _acc = __3Cundefined_3E;

static long ___L__821__eval_2El__1244[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__819__eval_2El__1244;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__824__eval_2El__1244;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__826__eval_2El__1244;
  _acc = __3Clong_3E;
  goto ___L__827__eval_2El__1244;

static long ___L__826__eval_2El__1244[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__827__eval_2El__1244[] = {
  goto ___L__825__eval_2El__1244;

static long ___L__824__eval_2El__1244[] = {
  _acc = __3Cundefined_3E;

static long ___L__825__eval_2El__1244[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__819__eval_2El__1244[] = {
  if (_acc == nil) goto ___L__817__eval_2El__1244;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = (getLong(_acc) > getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__828__eval_2El__1244;
  _acc = _s__t;

static long ___L__828__eval_2El__1244[] = {
  goto ___L__818__eval_2El__1244;

static long ___L__817__eval_2El__1244[] = {

static long ___L__829__eval_2El__1244[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__829__eval_2El__1244;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__830__eval_2El__1244[] = {
  "non-numeric argument: ("
,
    _acc = (oop)___L__830__eval_2El__1244;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__831__eval_2El__1244[] = {
  "gt"
,
    _acc = (oop)___L__831__eval_2El__1244;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__832__eval_2El__1244[] = {
  " "
,
    _acc = (oop)___L__832__eval_2El__1244;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__833__eval_2El__1244[] = {
  " "
,
    _acc = (oop)___L__833__eval_2El__1244;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__834__eval_2El__1244[] = {
  ")"
,
    _acc = (oop)___L__834__eval_2El__1244;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__835__eval_2El__1244[] = {
  "\012"
,
    _acc = (oop)___L__835__eval_2El__1244;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__818__eval_2El__1244[] = {
return _acc;
}

oop subr_gt = (oop)subr_gt;
## defn subr_ge
oop subr_ge(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__836__eval_2El__1243[] = {

static long ___L__837__eval_2El__1243[] = {
  "ge"
,
    _acc = (oop)___L__837__eval_2El__1243;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__841__eval_2El__1243;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__843__eval_2El__1243;
  _acc = __3Clong_3E;
  goto ___L__844__eval_2El__1243;

static long ___L__843__eval_2El__1243[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__844__eval_2El__1243[] = {
  goto ___L__842__eval_2El__1243;

static long ___L__841__eval_2El__1243[] = {
  _acc = __3Cundefined_3E;

static long ___L__842__eval_2El__1243[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__840__eval_2El__1243;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__845__eval_2El__1243;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__847__eval_2El__1243;
  _acc = __3Clong_3E;
  goto ___L__848__eval_2El__1243;

static long ___L__847__eval_2El__1243[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__848__eval_2El__1243[] = {
  goto ___L__846__eval_2El__1243;

static long ___L__845__eval_2El__1243[] = {
  _acc = __3Cundefined_3E;

static long ___L__846__eval_2El__1243[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__840__eval_2El__1243[] = {
  if (_acc == nil) goto ___L__838__eval_2El__1243;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = (getLong(_acc) >= getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__849__eval_2El__1243;
  _acc = _s__t;

static long ___L__849__eval_2El__1243[] = {
  goto ___L__839__eval_2El__1243;

static long ___L__838__eval_2El__1243[] = {

static long ___L__850__eval_2El__1243[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__850__eval_2El__1243;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__851__eval_2El__1243[] = {
  "non-numeric argument: ("
,
    _acc = (oop)___L__851__eval_2El__1243;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__852__eval_2El__1243[] = {
  "ge"
,
    _acc = (oop)___L__852__eval_2El__1243;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__853__eval_2El__1243[] = {
  " "
,
    _acc = (oop)___L__853__eval_2El__1243;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__854__eval_2El__1243[] = {
  " "
,
    _acc = (oop)___L__854__eval_2El__1243;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__855__eval_2El__1243[] = {
  ")"
,
    _acc = (oop)___L__855__eval_2El__1243;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__856__eval_2El__1243[] = {
  "\012"
,
    _acc = (oop)___L__856__eval_2El__1243;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__839__eval_2El__1243[] = {
return _acc;
}

oop subr_ge = (oop)subr_ge;
## defn subr_le
oop subr_le(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__857__eval_2El__1242[] = {

static long ___L__858__eval_2El__1242[] = {
  "le"
,
    _acc = (oop)___L__858__eval_2El__1242;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__862__eval_2El__1242;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__864__eval_2El__1242;
  _acc = __3Clong_3E;
  goto ___L__865__eval_2El__1242;

static long ___L__864__eval_2El__1242[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__865__eval_2El__1242[] = {
  goto ___L__863__eval_2El__1242;

static long ___L__862__eval_2El__1242[] = {
  _acc = __3Cundefined_3E;

static long ___L__863__eval_2El__1242[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__861__eval_2El__1242;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__866__eval_2El__1242;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__868__eval_2El__1242;
  _acc = __3Clong_3E;
  goto ___L__869__eval_2El__1242;

static long ___L__868__eval_2El__1242[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__869__eval_2El__1242[] = {
  goto ___L__867__eval_2El__1242;

static long ___L__866__eval_2El__1242[] = {
  _acc = __3Cundefined_3E;

static long ___L__867__eval_2El__1242[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__861__eval_2El__1242[] = {
  if (_acc == nil) goto ___L__859__eval_2El__1242;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = (getLong(_acc) <= getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__870__eval_2El__1242;
  _acc = _s__t;

static long ___L__870__eval_2El__1242[] = {
  goto ___L__860__eval_2El__1242;

static long ___L__859__eval_2El__1242[] = {

static long ___L__871__eval_2El__1242[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__871__eval_2El__1242;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__872__eval_2El__1242[] = {
  "non-numeric argument: ("
,
    _acc = (oop)___L__872__eval_2El__1242;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__873__eval_2El__1242[] = {
  "le"
,
    _acc = (oop)___L__873__eval_2El__1242;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__874__eval_2El__1242[] = {
  " "
,
    _acc = (oop)___L__874__eval_2El__1242;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__875__eval_2El__1242[] = {
  " "
,
    _acc = (oop)___L__875__eval_2El__1242;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__876__eval_2El__1242[] = {
  ")"
,
    _acc = (oop)___L__876__eval_2El__1242;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__877__eval_2El__1242[] = {
  "\012"
,
    _acc = (oop)___L__877__eval_2El__1242;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__860__eval_2El__1242[] = {
return _acc;
}

oop subr_le = (oop)subr_le;
## defn subr_lt
oop subr_lt(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__878__eval_2El__1241[] = {

static long ___L__879__eval_2El__1241[] = {
  "lt"
,
    _acc = (oop)___L__879__eval_2El__1241;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__883__eval_2El__1241;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__885__eval_2El__1241;
  _acc = __3Clong_3E;
  goto ___L__886__eval_2El__1241;

static long ___L__885__eval_2El__1241[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__886__eval_2El__1241[] = {
  goto ___L__884__eval_2El__1241;

static long ___L__883__eval_2El__1241[] = {
  _acc = __3Cundefined_3E;

static long ___L__884__eval_2El__1241[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__882__eval_2El__1241;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__887__eval_2El__1241;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__889__eval_2El__1241;
  _acc = __3Clong_3E;
  goto ___L__890__eval_2El__1241;

static long ___L__889__eval_2El__1241[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__890__eval_2El__1241[] = {
  goto ___L__888__eval_2El__1241;

static long ___L__887__eval_2El__1241[] = {
  _acc = __3Cundefined_3E;

static long ___L__888__eval_2El__1241[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__882__eval_2El__1241[] = {
  if (_acc == nil) goto ___L__880__eval_2El__1241;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = (getLong(_acc) < getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__891__eval_2El__1241;
  _acc = _s__t;

static long ___L__891__eval_2El__1241[] = {
  goto ___L__881__eval_2El__1241;

static long ___L__880__eval_2El__1241[] = {

static long ___L__892__eval_2El__1241[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__892__eval_2El__1241;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__893__eval_2El__1241[] = {
  "non-numeric argument: ("
,
    _acc = (oop)___L__893__eval_2El__1241;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__894__eval_2El__1241[] = {
  "lt"
,
    _acc = (oop)___L__894__eval_2El__1241;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__895__eval_2El__1241[] = {
  " "
,
    _acc = (oop)___L__895__eval_2El__1241;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__896__eval_2El__1241[] = {
  " "
,
    _acc = (oop)___L__896__eval_2El__1241;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__897__eval_2El__1241[] = {
  ")"
,
    _acc = (oop)___L__897__eval_2El__1241;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__898__eval_2El__1241[] = {
  "\012"
,
    _acc = (oop)___L__898__eval_2El__1241;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__881__eval_2El__1241[] = {
return _acc;
}

oop subr_lt = (oop)subr_lt;
## defn define-relation
/* form define-relation */
## defn subr_shr
oop subr_shr(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__899__eval_2El__1230[] = {

static long ___L__900__eval_2El__1230[] = {
  "shr"
,
    _acc = (oop)___L__900__eval_2El__1230;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__904__eval_2El__1230;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__906__eval_2El__1230;
  _acc = __3Clong_3E;
  goto ___L__907__eval_2El__1230;

static long ___L__906__eval_2El__1230[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__907__eval_2El__1230[] = {
  goto ___L__905__eval_2El__1230;

static long ___L__904__eval_2El__1230[] = {
  _acc = __3Cundefined_3E;

static long ___L__905__eval_2El__1230[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__903__eval_2El__1230;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__908__eval_2El__1230;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__910__eval_2El__1230;
  _acc = __3Clong_3E;
  goto ___L__911__eval_2El__1230;

static long ___L__910__eval_2El__1230[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__911__eval_2El__1230[] = {
  goto ___L__909__eval_2El__1230;

static long ___L__908__eval_2El__1230[] = {
  _acc = __3Cundefined_3E;

static long ___L__909__eval_2El__1230[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__903__eval_2El__1230[] = {
  if (_acc == nil) goto ___L__901__eval_2El__1230;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = LONG(getLong(_acc) >> getLong(_tmp2));
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__902__eval_2El__1230;

static long ___L__901__eval_2El__1230[] = {

static long ___L__912__eval_2El__1230[] = {
  "%p %p\012"
,
    _acc = (oop)___L__912__eval_2El__1230;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__913__eval_2El__1230[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__913__eval_2El__1230;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__914__eval_2El__1230[] = {
  "non-numeric argument: ("
,
    _acc = (oop)___L__914__eval_2El__1230;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__915__eval_2El__1230[] = {
  "shr"
,
    _acc = (oop)___L__915__eval_2El__1230;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__916__eval_2El__1230[] = {
  " "
,
    _acc = (oop)___L__916__eval_2El__1230;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__917__eval_2El__1230[] = {
  " "
,
    _acc = (oop)___L__917__eval_2El__1230;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__918__eval_2El__1230[] = {
  ")"
,
    _acc = (oop)___L__918__eval_2El__1230;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__919__eval_2El__1230[] = {
  "\012"
,
    _acc = (oop)___L__919__eval_2El__1230;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__902__eval_2El__1230[] = {
return _acc;
}

oop subr_shr = (oop)subr_shr;
## defn subr_shl
oop subr_shl(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__920__eval_2El__1229[] = {

static long ___L__921__eval_2El__1229[] = {
  "shl"
,
    _acc = (oop)___L__921__eval_2El__1229;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__925__eval_2El__1229;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__927__eval_2El__1229;
  _acc = __3Clong_3E;
  goto ___L__928__eval_2El__1229;

static long ___L__927__eval_2El__1229[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__928__eval_2El__1229[] = {
  goto ___L__926__eval_2El__1229;

static long ___L__925__eval_2El__1229[] = {
  _acc = __3Cundefined_3E;

static long ___L__926__eval_2El__1229[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__924__eval_2El__1229;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__929__eval_2El__1229;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__931__eval_2El__1229;
  _acc = __3Clong_3E;
  goto ___L__932__eval_2El__1229;

static long ___L__931__eval_2El__1229[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__932__eval_2El__1229[] = {
  goto ___L__930__eval_2El__1229;

static long ___L__929__eval_2El__1229[] = {
  _acc = __3Cundefined_3E;

static long ___L__930__eval_2El__1229[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__924__eval_2El__1229[] = {
  if (_acc == nil) goto ___L__922__eval_2El__1229;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = LONG(getLong(_acc) << getLong(_tmp2));
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__923__eval_2El__1229;

static long ___L__922__eval_2El__1229[] = {

static long ___L__933__eval_2El__1229[] = {
  "%p %p\012"
,
    _acc = (oop)___L__933__eval_2El__1229;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__934__eval_2El__1229[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__934__eval_2El__1229;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__935__eval_2El__1229[] = {
  "non-numeric argument: ("
,
    _acc = (oop)___L__935__eval_2El__1229;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__936__eval_2El__1229[] = {
  "shl"
,
    _acc = (oop)___L__936__eval_2El__1229;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__937__eval_2El__1229[] = {
  " "
,
    _acc = (oop)___L__937__eval_2El__1229;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__938__eval_2El__1229[] = {
  " "
,
    _acc = (oop)___L__938__eval_2El__1229;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__939__eval_2El__1229[] = {
  ")"
,
    _acc = (oop)___L__939__eval_2El__1229;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__940__eval_2El__1229[] = {
  "\012"
,
    _acc = (oop)___L__940__eval_2El__1229;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__923__eval_2El__1229[] = {
return _acc;
}

oop subr_shl = (oop)subr_shl;
## defn subr_div
oop subr_div(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__941__eval_2El__1228[] = {

static long ___L__942__eval_2El__1228[] = {
  "div"
,
    _acc = (oop)___L__942__eval_2El__1228;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__946__eval_2El__1228;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__948__eval_2El__1228;
  _acc = __3Clong_3E;
  goto ___L__949__eval_2El__1228;

static long ___L__948__eval_2El__1228[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__949__eval_2El__1228[] = {
  goto ___L__947__eval_2El__1228;

static long ___L__946__eval_2El__1228[] = {
  _acc = __3Cundefined_3E;

static long ___L__947__eval_2El__1228[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__945__eval_2El__1228;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__950__eval_2El__1228;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__952__eval_2El__1228;
  _acc = __3Clong_3E;
  goto ___L__953__eval_2El__1228;

static long ___L__952__eval_2El__1228[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__953__eval_2El__1228[] = {
  goto ___L__951__eval_2El__1228;

static long ___L__950__eval_2El__1228[] = {
  _acc = __3Cundefined_3E;

static long ___L__951__eval_2El__1228[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__945__eval_2El__1228[] = {
  if (_acc == nil) goto ___L__943__eval_2El__1228;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = LONG(getLong(_acc) / getLong(_tmp2));
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__944__eval_2El__1228;

static long ___L__943__eval_2El__1228[] = {

static long ___L__954__eval_2El__1228[] = {
  "%p %p\012"
,
    _acc = (oop)___L__954__eval_2El__1228;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__955__eval_2El__1228[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__955__eval_2El__1228;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__956__eval_2El__1228[] = {
  "non-numeric argument: ("
,
    _acc = (oop)___L__956__eval_2El__1228;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__957__eval_2El__1228[] = {
  "div"
,
    _acc = (oop)___L__957__eval_2El__1228;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__958__eval_2El__1228[] = {
  " "
,
    _acc = (oop)___L__958__eval_2El__1228;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__959__eval_2El__1228[] = {
  " "
,
    _acc = (oop)___L__959__eval_2El__1228;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__960__eval_2El__1228[] = {
  ")"
,
    _acc = (oop)___L__960__eval_2El__1228;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__961__eval_2El__1228[] = {
  "\012"
,
    _acc = (oop)___L__961__eval_2El__1228;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__944__eval_2El__1228[] = {
return _acc;
}

oop subr_div = (oop)subr_div;
## defn subr_mul
oop subr_mul(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__962__eval_2El__1227[] = {

static long ___L__963__eval_2El__1227[] = {
  "mul"
,
    _acc = (oop)___L__963__eval_2El__1227;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__967__eval_2El__1227;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__969__eval_2El__1227;
  _acc = __3Clong_3E;
  goto ___L__970__eval_2El__1227;

static long ___L__969__eval_2El__1227[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__970__eval_2El__1227[] = {
  goto ___L__968__eval_2El__1227;

static long ___L__967__eval_2El__1227[] = {
  _acc = __3Cundefined_3E;

static long ___L__968__eval_2El__1227[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__966__eval_2El__1227;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__971__eval_2El__1227;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__973__eval_2El__1227;
  _acc = __3Clong_3E;
  goto ___L__974__eval_2El__1227;

static long ___L__973__eval_2El__1227[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__974__eval_2El__1227[] = {
  goto ___L__972__eval_2El__1227;

static long ___L__971__eval_2El__1227[] = {
  _acc = __3Cundefined_3E;

static long ___L__972__eval_2El__1227[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__966__eval_2El__1227[] = {
  if (_acc == nil) goto ___L__964__eval_2El__1227;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = LONG(getLong(_acc) * getLong(_tmp2));
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__965__eval_2El__1227;

static long ___L__964__eval_2El__1227[] = {

static long ___L__975__eval_2El__1227[] = {
  "%p %p\012"
,
    _acc = (oop)___L__975__eval_2El__1227;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__976__eval_2El__1227[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__976__eval_2El__1227;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__977__eval_2El__1227[] = {
  "non-numeric argument: ("
,
    _acc = (oop)___L__977__eval_2El__1227;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__978__eval_2El__1227[] = {
  "mul"
,
    _acc = (oop)___L__978__eval_2El__1227;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__979__eval_2El__1227[] = {
  " "
,
    _acc = (oop)___L__979__eval_2El__1227;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__980__eval_2El__1227[] = {
  " "
,
    _acc = (oop)___L__980__eval_2El__1227;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__981__eval_2El__1227[] = {
  ")"
,
    _acc = (oop)___L__981__eval_2El__1227;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__982__eval_2El__1227[] = {
  "\012"
,
    _acc = (oop)___L__982__eval_2El__1227;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__965__eval_2El__1227[] = {
return _acc;
}

oop subr_mul = (oop)subr_mul;
## defn subr_add
oop subr_add(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__983__eval_2El__1226[] = {

static long ___L__984__eval_2El__1226[] = {
  "add"
,
    _acc = (oop)___L__984__eval_2El__1226;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__988__eval_2El__1226;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__990__eval_2El__1226;
  _acc = __3Clong_3E;
  goto ___L__991__eval_2El__1226;

static long ___L__990__eval_2El__1226[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__991__eval_2El__1226[] = {
  goto ___L__989__eval_2El__1226;

static long ___L__988__eval_2El__1226[] = {
  _acc = __3Cundefined_3E;

static long ___L__989__eval_2El__1226[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__987__eval_2El__1226;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__992__eval_2El__1226;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__994__eval_2El__1226;
  _acc = __3Clong_3E;
  goto ___L__995__eval_2El__1226;

static long ___L__994__eval_2El__1226[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__995__eval_2El__1226[] = {
  goto ___L__993__eval_2El__1226;

static long ___L__992__eval_2El__1226[] = {
  _acc = __3Cundefined_3E;

static long ___L__993__eval_2El__1226[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__987__eval_2El__1226[] = {
  if (_acc == nil) goto ___L__985__eval_2El__1226;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = LONG(getLong(_acc) + getLong(_tmp2));
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__986__eval_2El__1226;

static long ___L__985__eval_2El__1226[] = {

static long ___L__996__eval_2El__1226[] = {
  "%p %p\012"
,
    _acc = (oop)___L__996__eval_2El__1226;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__997__eval_2El__1226[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__997__eval_2El__1226;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__998__eval_2El__1226[] = {
  "non-numeric argument: ("
,
    _acc = (oop)___L__998__eval_2El__1226;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__999__eval_2El__1226[] = {
  "add"
,
    _acc = (oop)___L__999__eval_2El__1226;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1000__eval_2El__1226[] = {
  " "
,
    _acc = (oop)___L__1000__eval_2El__1226;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1001__eval_2El__1226[] = {
  " "
,
    _acc = (oop)___L__1001__eval_2El__1226;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1002__eval_2El__1226[] = {
  ")"
,
    _acc = (oop)___L__1002__eval_2El__1226;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1003__eval_2El__1226[] = {
  "\012"
,
    _acc = (oop)___L__1003__eval_2El__1226;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__986__eval_2El__1226[] = {
return _acc;
}

oop subr_add = (oop)subr_add;
## defn subr_bitxor
oop subr_bitxor(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1004__eval_2El__1225[] = {

static long ___L__1005__eval_2El__1225[] = {
  "bitxor"
,
    _acc = (oop)___L__1005__eval_2El__1225;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1009__eval_2El__1225;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1011__eval_2El__1225;
  _acc = __3Clong_3E;
  goto ___L__1012__eval_2El__1225;

static long ___L__1011__eval_2El__1225[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1012__eval_2El__1225[] = {
  goto ___L__1010__eval_2El__1225;

static long ___L__1009__eval_2El__1225[] = {
  _acc = __3Cundefined_3E;

static long ___L__1010__eval_2El__1225[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1008__eval_2El__1225;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1013__eval_2El__1225;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1015__eval_2El__1225;
  _acc = __3Clong_3E;
  goto ___L__1016__eval_2El__1225;

static long ___L__1015__eval_2El__1225[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1016__eval_2El__1225[] = {
  goto ___L__1014__eval_2El__1225;

static long ___L__1013__eval_2El__1225[] = {
  _acc = __3Cundefined_3E;

static long ___L__1014__eval_2El__1225[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__1008__eval_2El__1225[] = {
  if (_acc == nil) goto ___L__1006__eval_2El__1225;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = LONG(getLong(_acc) ^ getLong(_tmp2));
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__1007__eval_2El__1225;

static long ___L__1006__eval_2El__1225[] = {

static long ___L__1017__eval_2El__1225[] = {
  "%p %p\012"
,
    _acc = (oop)___L__1017__eval_2El__1225;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__1018__eval_2El__1225[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__1018__eval_2El__1225;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1019__eval_2El__1225[] = {
  "non-numeric argument: ("
,
    _acc = (oop)___L__1019__eval_2El__1225;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1020__eval_2El__1225[] = {
  "bitxor"
,
    _acc = (oop)___L__1020__eval_2El__1225;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1021__eval_2El__1225[] = {
  " "
,
    _acc = (oop)___L__1021__eval_2El__1225;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1022__eval_2El__1225[] = {
  " "
,
    _acc = (oop)___L__1022__eval_2El__1225;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1023__eval_2El__1225[] = {
  ")"
,
    _acc = (oop)___L__1023__eval_2El__1225;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1024__eval_2El__1225[] = {
  "\012"
,
    _acc = (oop)___L__1024__eval_2El__1225;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__1007__eval_2El__1225[] = {
return _acc;
}

oop subr_bitxor = (oop)subr_bitxor;
## defn subr_bitor
oop subr_bitor(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1025__eval_2El__1224[] = {

static long ___L__1026__eval_2El__1224[] = {
  "bitor"
,
    _acc = (oop)___L__1026__eval_2El__1224;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1030__eval_2El__1224;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1032__eval_2El__1224;
  _acc = __3Clong_3E;
  goto ___L__1033__eval_2El__1224;

static long ___L__1032__eval_2El__1224[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1033__eval_2El__1224[] = {
  goto ___L__1031__eval_2El__1224;

static long ___L__1030__eval_2El__1224[] = {
  _acc = __3Cundefined_3E;

static long ___L__1031__eval_2El__1224[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1029__eval_2El__1224;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1034__eval_2El__1224;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1036__eval_2El__1224;
  _acc = __3Clong_3E;
  goto ___L__1037__eval_2El__1224;

static long ___L__1036__eval_2El__1224[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1037__eval_2El__1224[] = {
  goto ___L__1035__eval_2El__1224;

static long ___L__1034__eval_2El__1224[] = {
  _acc = __3Cundefined_3E;

static long ___L__1035__eval_2El__1224[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__1029__eval_2El__1224[] = {
  if (_acc == nil) goto ___L__1027__eval_2El__1224;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = LONG(getLong(_acc) | getLong(_tmp2));
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__1028__eval_2El__1224;

static long ___L__1027__eval_2El__1224[] = {

static long ___L__1038__eval_2El__1224[] = {
  "%p %p\012"
,
    _acc = (oop)___L__1038__eval_2El__1224;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__1039__eval_2El__1224[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__1039__eval_2El__1224;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1040__eval_2El__1224[] = {
  "non-numeric argument: ("
,
    _acc = (oop)___L__1040__eval_2El__1224;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1041__eval_2El__1224[] = {
  "bitor"
,
    _acc = (oop)___L__1041__eval_2El__1224;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1042__eval_2El__1224[] = {
  " "
,
    _acc = (oop)___L__1042__eval_2El__1224;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1043__eval_2El__1224[] = {
  " "
,
    _acc = (oop)___L__1043__eval_2El__1224;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1044__eval_2El__1224[] = {
  ")"
,
    _acc = (oop)___L__1044__eval_2El__1224;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1045__eval_2El__1224[] = {
  "\012"
,
    _acc = (oop)___L__1045__eval_2El__1224;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__1028__eval_2El__1224[] = {
return _acc;
}

oop subr_bitor = (oop)subr_bitor;
## defn subr_bitand
oop subr_bitand(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1046__eval_2El__1223[] = {

static long ___L__1047__eval_2El__1223[] = {
  "bitand"
,
    _acc = (oop)___L__1047__eval_2El__1223;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _arity2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1051__eval_2El__1223;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1053__eval_2El__1223;
  _acc = __3Clong_3E;
  goto ___L__1054__eval_2El__1223;

static long ___L__1053__eval_2El__1223[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1054__eval_2El__1223[] = {
  goto ___L__1052__eval_2El__1223;

static long ___L__1051__eval_2El__1223[] = {
  _acc = __3Cundefined_3E;

static long ___L__1052__eval_2El__1223[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1050__eval_2El__1223;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1055__eval_2El__1223;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1057__eval_2El__1223;
  _acc = __3Clong_3E;
  goto ___L__1058__eval_2El__1223;

static long ___L__1057__eval_2El__1223[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1058__eval_2El__1223[] = {
  goto ___L__1056__eval_2El__1223;

static long ___L__1055__eval_2El__1223[] = {
  _acc = __3Cundefined_3E;

static long ___L__1056__eval_2El__1223[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__1050__eval_2El__1223[] = {
  if (_acc == nil) goto ___L__1048__eval_2El__1223;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__1049__eval_2El__1223;

static long ___L__1048__eval_2El__1223[] = {

static long ___L__1059__eval_2El__1223[] = {
  "%p %p\012"
,
    _acc = (oop)___L__1059__eval_2El__1223;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__1060__eval_2El__1223[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__1060__eval_2El__1223;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1061__eval_2El__1223[] = {
  "non-numeric argument: ("
,
    _acc = (oop)___L__1061__eval_2El__1223;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1062__eval_2El__1223[] = {
  "bitand"
,
    _acc = (oop)___L__1062__eval_2El__1223;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1063__eval_2El__1223[] = {
  " "
,
    _acc = (oop)___L__1063__eval_2El__1223;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1064__eval_2El__1223[] = {
  " "
,
    _acc = (oop)___L__1064__eval_2El__1223;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1065__eval_2El__1223[] = {
  ")"
,
    _acc = (oop)___L__1065__eval_2El__1223;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1066__eval_2El__1223[] = {
  "\012"
,
    _acc = (oop)___L__1066__eval_2El__1223;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__1049__eval_2El__1223[] = {
return _acc;
}

oop subr_bitand = (oop)subr_bitand;
## defn define-binary
/* form define-binary */
## defn subr_sub
oop subr_sub(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1067__eval_2El__1200[] = {
  _acc = _tmp0;
  if (_acc != nil) goto ___L__1068__eval_2El__1200;

static long ___L__1069__eval_2El__1200[] = {
  "-: expected 1 or 2 arguments"
,
    _acc = (oop)___L__1069__eval_2El__1200;
  _tmp0 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1068__eval_2El__1200[] = {

static long ___L__1070__eval_2El__1201[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__1071__eval_2El__1202[] = {
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;

static long ___L__1072__eval_2El__1203[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1076__eval_2El__1203;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1078__eval_2El__1203;
  _acc = __3Clong_3E;
  goto ___L__1079__eval_2El__1203;

static long ___L__1078__eval_2El__1203[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1079__eval_2El__1203[] = {
  goto ___L__1077__eval_2El__1203;

static long ___L__1076__eval_2El__1203[] = {
  _acc = __3Cundefined_3E;

static long ___L__1077__eval_2El__1203[] = {
  _tmp2 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__1075__eval_2El__1203[] = {
  if (_acc == nil) goto ___L__1073__eval_2El__1203;

static long ___L__1080__eval_2El__1204[] = {

static long ___L__1081__eval_2El__1205[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp1 = _acc;

static long ___L__1082__eval_2El__1206[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1086__eval_2El__1206;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1088__eval_2El__1206;
  _acc = __3Clong_3E;
  goto ___L__1089__eval_2El__1206;

static long ___L__1088__eval_2El__1206[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1089__eval_2El__1206[] = {
  goto ___L__1087__eval_2El__1206;

static long ___L__1086__eval_2El__1206[] = {
  _acc = __3Cundefined_3E;

static long ___L__1087__eval_2El__1206[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1085__eval_2El__1206;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1090__eval_2El__1206;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1092__eval_2El__1206;
  _acc = __3Clong_3E;
  goto ___L__1093__eval_2El__1206;

static long ___L__1092__eval_2El__1206[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1093__eval_2El__1206[] = {
  goto ___L__1091__eval_2El__1206;

static long ___L__1090__eval_2El__1206[] = {
  _acc = __3Cundefined_3E;

static long ___L__1091__eval_2El__1206[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__1085__eval_2El__1206[] = {
  if (_acc == nil) goto ___L__1083__eval_2El__1206;

static long ___L__1094__eval_2El__1207[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = LONG(getLong(_acc) - getLong(_tmp2));
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__1084__eval_2El__1206;

static long ___L__1083__eval_2El__1206[] = {

static long ___L__1095__eval_2El__1208[] = {

static long ___L__1096__eval_2El__1208[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__1096__eval_2El__1208;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1097__eval_2El__1208[] = {
  "non-numeric argument: (- "
,
    _acc = (oop)___L__1097__eval_2El__1208;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1098__eval_2El__1208[] = {
  " "
,
    _acc = (oop)___L__1098__eval_2El__1208;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1099__eval_2El__1208[] = {
  ")"
,
    _acc = (oop)___L__1099__eval_2El__1208;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1100__eval_2El__1208[] = {
  "\012"
,
    _acc = (oop)___L__1100__eval_2El__1208;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__1084__eval_2El__1206[] = {
  goto ___L__1074__eval_2El__1203;

static long ___L__1073__eval_2El__1203[] = {

static long ___L__1101__eval_2El__1209[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1105__eval_2El__1209;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1107__eval_2El__1209;
  _acc = __3Clong_3E;
  goto ___L__1108__eval_2El__1209;

static long ___L__1107__eval_2El__1209[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1108__eval_2El__1209[] = {
  goto ___L__1106__eval_2El__1209;

static long ___L__1105__eval_2El__1209[] = {
  _acc = __3Cundefined_3E;

static long ___L__1106__eval_2El__1209[] = {
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);

static long ___L__1104__eval_2El__1209[] = {
  if (_acc == nil) goto ___L__1102__eval_2El__1209;

static long ___L__1109__eval_2El__1210[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _acc = LONG(-getLong(_acc));
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__1103__eval_2El__1209;

static long ___L__1102__eval_2El__1209[] = {

static long ___L__1110__eval_2El__1211[] = {

static long ___L__1111__eval_2El__1211[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__1111__eval_2El__1211;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1112__eval_2El__1211[] = {
  "non-numeric argument: (- "
,
    _acc = (oop)___L__1112__eval_2El__1211;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1113__eval_2El__1211[] = {
  ")"
,
    _acc = (oop)___L__1113__eval_2El__1211;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1114__eval_2El__1211[] = {
  "\012"
,
    _acc = (oop)___L__1114__eval_2El__1211;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__1103__eval_2El__1209[] = {

static long ___L__1074__eval_2El__1203[] = {
return _acc;
}

oop subr_sub = (oop)subr_sub;
## defn arity3
oop arity3(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1115__eval_2El__1193[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1118__eval_2El__1193;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1120__eval_2El__1193;
  _acc = __3Clong_3E;
  goto ___L__1121__eval_2El__1193;

static long ___L__1120__eval_2El__1193[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1121__eval_2El__1193[] = {
  goto ___L__1119__eval_2El__1193;

static long ___L__1118__eval_2El__1193[] = {
  _acc = __3Cundefined_3E;

static long ___L__1119__eval_2El__1193[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1117__eval_2El__1193;

static long ___L__1122__eval_2El__1194[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1123__eval_2El__1194;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1125__eval_2El__1194;
  _acc = __3Clong_3E;
  goto ___L__1126__eval_2El__1194;

static long ___L__1125__eval_2El__1194[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1126__eval_2El__1194[] = {
  goto ___L__1124__eval_2El__1194;

static long ___L__1123__eval_2El__1194[] = {
  _acc = __3Cundefined_3E;

static long ___L__1124__eval_2El__1194[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1117__eval_2El__1193;

static long ___L__1127__eval_2El__1195[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1128__eval_2El__1195;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1130__eval_2El__1195;
  _acc = __3Clong_3E;
  goto ___L__1131__eval_2El__1195;

static long ___L__1130__eval_2El__1195[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1131__eval_2El__1195[] = {
  goto ___L__1129__eval_2El__1195;

static long ___L__1128__eval_2El__1195[] = {
  _acc = __3Cundefined_3E;

static long ___L__1129__eval_2El__1195[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1117__eval_2El__1193;

static long ___L__1132__eval_2El__1196[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);

static long ___L__1117__eval_2El__1193[] = {
  if (_acc != nil) goto ___L__1116__eval_2El__1193;

static long ___L__1133__eval_2El__1197[] = {

static long ___L__1134__eval_2El__1197[] = {
  "%s: expected 3 arguments"
,
    _acc = (oop)___L__1134__eval_2El__1197;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _fatal1;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1116__eval_2El__1193[] = {
return _acc;
}

oop arity3 = (oop)arity3;
## defn arity2
oop arity2(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1135__eval_2El__1187[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1138__eval_2El__1187;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1140__eval_2El__1187;
  _acc = __3Clong_3E;
  goto ___L__1141__eval_2El__1187;

static long ___L__1140__eval_2El__1187[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1141__eval_2El__1187[] = {
  goto ___L__1139__eval_2El__1187;

static long ___L__1138__eval_2El__1187[] = {
  _acc = __3Cundefined_3E;

static long ___L__1139__eval_2El__1187[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1137__eval_2El__1187;

static long ___L__1142__eval_2El__1188[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1143__eval_2El__1188;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1145__eval_2El__1188;
  _acc = __3Clong_3E;
  goto ___L__1146__eval_2El__1188;

static long ___L__1145__eval_2El__1188[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1146__eval_2El__1188[] = {
  goto ___L__1144__eval_2El__1188;

static long ___L__1143__eval_2El__1188[] = {
  _acc = __3Cundefined_3E;

static long ___L__1144__eval_2El__1188[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1137__eval_2El__1187;

static long ___L__1147__eval_2El__1189[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);

static long ___L__1137__eval_2El__1187[] = {
  if (_acc != nil) goto ___L__1136__eval_2El__1187;

static long ___L__1148__eval_2El__1190[] = {

static long ___L__1149__eval_2El__1190[] = {
  "%s: expected 2 arguments"
,
    _acc = (oop)___L__1149__eval_2El__1190;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _fatal1;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1136__eval_2El__1187[] = {
return _acc;
}

oop arity2 = (oop)arity2;
## defn subr_not
oop subr_not(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1150__eval_2El__1184[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__1151__eval_2El__1184;
  _acc = LONG(0);
  goto ___L__1152__eval_2El__1184;

static long ___L__1151__eval_2El__1184[] = {
  _acc = _s__t;

static long ___L__1152__eval_2El__1184[] = {
return _acc;
}

oop subr_not = (oop)subr_not;
## defn subr_quote
oop subr_quote(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1153__eval_2El__1181[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop subr_quote = (oop)subr_quote;
## defn subr_and
oop subr_and(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1154__eval_2El__1173[] = {
  _acc = _s__t;
  _tmp0 = _acc;

static long ___L__1155__eval_2El__1174[] = {
  goto ___L__1157__eval_2El__1174;

static long ___L__1156__eval_2El__1174[] = {

static long ___L__1158__eval_2El__1175[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  if (_acc != nil) goto ___L__1159__eval_2El__1175;

static long ___L__1160__eval_2El__1176[] = {
  _acc = LONG(0);
  goto ___L__1161__eval_2El__1176;

static long ___L__1159__eval_2El__1175[] = {

static long ___L__1162__eval_2El__1177[] = {
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp0 = _acc;

static long ___L__1157__eval_2El__1174[] = {

static long ___L__1163__eval_2El__1174[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1164__eval_2El__1174;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1166__eval_2El__1174;
  _acc = __3Clong_3E;
  goto ___L__1167__eval_2El__1174;

static long ___L__1166__eval_2El__1174[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1167__eval_2El__1174[] = {
  goto ___L__1165__eval_2El__1174;

static long ___L__1164__eval_2El__1174[] = {
  _acc = __3Cundefined_3E;

static long ___L__1165__eval_2El__1174[] = {
  _tmp2 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1156__eval_2El__1174;
  _acc = _tmp0;
___L__1161__eval_2El__1176:
  return _acc;
}

oop subr_and = (oop)subr_and;
## defn subr_or
oop subr_or(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1168__eval_2El__1166[] = {
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__1169__eval_2El__1167[] = {
  goto ___L__1171__eval_2El__1167;

static long ___L__1170__eval_2El__1167[] = {

static long ___L__1172__eval_2El__1168[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  if (_acc == nil) goto ___L__1173__eval_2El__1168;

static long ___L__1174__eval_2El__1169[] = {
  _acc = _tmp0;
  goto ___L__1175__eval_2El__1169;

static long ___L__1173__eval_2El__1168[] = {

static long ___L__1176__eval_2El__1170[] = {
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp0 = _acc;

static long ___L__1171__eval_2El__1167[] = {

static long ___L__1177__eval_2El__1167[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1178__eval_2El__1167;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1180__eval_2El__1167;
  _acc = __3Clong_3E;
  goto ___L__1181__eval_2El__1167;

static long ___L__1180__eval_2El__1167[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1181__eval_2El__1167[] = {
  goto ___L__1179__eval_2El__1167;

static long ___L__1178__eval_2El__1167[] = {
  _acc = __3Cundefined_3E;

static long ___L__1179__eval_2El__1167[] = {
  _tmp2 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1170__eval_2El__1167;
___L__1175__eval_2El__1169:
  return _acc;
}

oop subr_or = (oop)subr_or;
## defn subr_if
oop subr_if(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1182__eval_2El__1157[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  if (_acc == nil) goto ___L__1183__eval_2El__1157;

static long ___L__1185__eval_2El__1158[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp1;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__1184__eval_2El__1157;

static long ___L__1183__eval_2El__1157[] = {

static long ___L__1186__eval_2El__1159[] = {
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__1187__eval_2El__1160[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cdr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__1188__eval_2El__1161[] = {
  goto ___L__1190__eval_2El__1161;

static long ___L__1189__eval_2El__1161[] = {

static long ___L__1191__eval_2El__1162[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__1190__eval_2El__1161[] = {

static long ___L__1192__eval_2El__1161[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__cdr;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1193__eval_2El__1161;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1195__eval_2El__1161;
  _acc = __3Clong_3E;
  goto ___L__1196__eval_2El__1161;

static long ___L__1195__eval_2El__1161[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1196__eval_2El__1161[] = {
  goto ___L__1194__eval_2El__1161;

static long ___L__1193__eval_2El__1161[] = {
  _acc = __3Cundefined_3E;

static long ___L__1194__eval_2El__1161[] = {
  _tmp2 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1189__eval_2El__1161;
  _acc = _tmp0;

static long ___L__1184__eval_2El__1157[] = {
return _acc;
}

oop subr_if = (oop)subr_if;
## defn subr_while
oop subr_while(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1197__eval_2El__1149[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;

static long ___L__1198__eval_2El__1151[] = {
  goto ___L__1200__eval_2El__1151;

static long ___L__1199__eval_2El__1151[] = {

static long ___L__1201__eval_2El__1152[] = {
  _acc = _tmp1;
  _tmp2 = _acc;

static long ___L__1202__eval_2El__1153[] = {
  goto ___L__1204__eval_2El__1153;

static long ___L__1203__eval_2El__1153[] = {

static long ___L__1205__eval_2El__1154[] = {
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1204__eval_2El__1153[] = {

static long ___L__1206__eval_2El__1153[] = {
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = _k__cdr;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = _tmp4;
  if (_acc == nil) goto ___L__1207__eval_2El__1153;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp4;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1209__eval_2El__1153;
  _acc = __3Clong_3E;
  goto ___L__1210__eval_2El__1153;

static long ___L__1209__eval_2El__1153[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp4;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1210__eval_2El__1153[] = {
  goto ___L__1208__eval_2El__1153;

static long ___L__1207__eval_2El__1153[] = {
  _acc = __3Cundefined_3E;

static long ___L__1208__eval_2El__1153[] = {
  _tmp4 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1203__eval_2El__1153;

static long ___L__1200__eval_2El__1151[] = {

static long ___L__1211__eval_2El__1151[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  if (_acc != nil) goto ___L__1199__eval_2El__1151;
return _acc;
}

oop subr_while = (oop)subr_while;
## defn subr_set
oop subr_set(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1212__eval_2El__1132[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__1213__eval_2El__1133[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__1215__eval_2El__1133;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__1217__eval_2El__1133;
  _acc = __3Clong_3E;
  goto ___L__1218__eval_2El__1133;

static long ___L__1217__eval_2El__1133[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__1218__eval_2El__1133[] = {
  goto ___L__1216__eval_2El__1133;

static long ___L__1215__eval_2El__1133[] = {
  _acc = __3Cundefined_3E;

static long ___L__1216__eval_2El__1133[] = {
  _tmp1 = _acc;
  _acc = __3Cvariable_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1214__eval_2El__1133;

static long ___L__1219__eval_2El__1134[] = {

static long ___L__1220__eval_2El__1135[] = {

static long ___L__1221__eval_2El__1135[] = {
  "\012cannot set undefined variable: "
,
    _acc = (oop)___L__1221__eval_2El__1135;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1222__eval_2El__1136[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__dumpln;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1223__eval_2El__1137[] = {

static long ___L__1224__eval_2El__1137[] = {
  "aborting"
,
    _acc = (oop)___L__1224__eval_2El__1137;
  _tmp1 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1214__eval_2El__1133[] = {

static long ___L__1225__eval_2El__1138[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1226__eval_2El__1139[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _is__global;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__1227__eval_2El__1139;

static long ___L__1229__eval_2El__1140[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cvariable_3E;
  _tmp5 = _acc;
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp4)] = _tmp3;
  goto ___L__1228__eval_2El__1139;

static long ___L__1227__eval_2El__1139[] = {

static long ___L__1230__eval_2El__1141[] = {

static long ___L__1231__eval_2El__1142[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp3 = _acc;
  _acc = __3Cvariable_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = __3Cenv_3E;
  _tmp6 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp1 = _acc;

static long ___L__1232__eval_2El__1141[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = __3Ccontext_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = __3Cenv_3E;
  _tmp5 = _acc;
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _acc = LONG(getLong(_acc) - getLong(_tmp1));
  _tmp1 = _acc;

static long ___L__1233__eval_2El__1143[] = {
  goto ___L__1235__eval_2El__1143;

static long ___L__1234__eval_2El__1143[] = {

static long ___L__1236__eval_2El__1144[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Ccontext_3E;
  _tmp5 = _acc;
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp1 = _acc;

static long ___L__1237__eval_2El__1145[] = {
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) - getLong(_tmp3));
  _tmp1 = _acc;

static long ___L__1235__eval_2El__1143[] = {

static long ___L__1238__eval_2El__1143[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = (getLong(_acc) < getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1234__eval_2El__1143;

static long ___L__1239__eval_2El__1146[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp6 = _acc;
  _acc = __3Ccontext_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp6 = _acc;
  _acc = LONG(0);
  _acc = LONG(3);
  _tmp5 = _acc;
  _acc = __3Cvariable_3E;
  _tmp4 = _acc;
  _acc = _tmp6;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp6 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp7 = _acc;
  _acc = _tmp6;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp6 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = _k__set__array__at;
  _tmp0 = _tmp3;
  _tmp1 = _tmp6;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__1228__eval_2El__1139[] = {
return _acc;
}

oop subr_set = (oop)subr_set;
## defn subr_let
oop subr_let(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1240__eval_2El__1108[] = {
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__1241__eval_2El__1109[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__1242__eval_2El__1108[] = {

static long ___L__1243__eval_2El__1110[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp3 = _acc;
  _acc = __3Ccontext_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;

static long ___L__1244__eval_2El__1108[] = {

static long ___L__1245__eval_2El__1111[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _k__cddr;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp3 = _acc;

static long ___L__1246__eval_2El__1112[] = {
  _acc = (oop)&_tmp0;
  _tmp5 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1247__eval_2El__1113[] = {
  goto ___L__1249__eval_2El__1113;

static long ___L__1248__eval_2El__1113[] = {

static long ___L__1250__eval_2El__1114[] = {
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp5 = _acc;

static long ___L__1251__eval_2El__1115[] = {
  _acc = _tmp5;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = _tmp4;
  if (_acc == nil) goto ___L__1254__eval_2El__1115;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp4;
  _acc = LONG(getLong(_acc) & getLong(_tmp6));
  if (_acc == nil) goto ___L__1256__eval_2El__1115;
  _acc = __3Clong_3E;
  goto ___L__1257__eval_2El__1115;

static long ___L__1256__eval_2El__1115[] = {
  _acc = LONG(-1);
  _tmp6 = _acc;
  _acc = _tmp4;
  _acc = ((oop*)_acc)[getLong(_tmp6)];

static long ___L__1257__eval_2El__1115[] = {
  goto ___L__1255__eval_2El__1115;

static long ___L__1254__eval_2El__1115[] = {
  _acc = __3Cundefined_3E;

static long ___L__1255__eval_2El__1115[] = {
  _tmp4 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1252__eval_2El__1115;

static long ___L__1258__eval_2El__1116[] = {
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = _tmp5;
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp4 = _acc;

static long ___L__1259__eval_2El__1117[] = {
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp5;
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp6 = _acc;

static long ___L__1260__eval_2El__1118[] = {
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__1261__eval_2El__1119[] = {
  goto ___L__1263__eval_2El__1119;

static long ___L__1262__eval_2El__1119[] = {

static long ___L__1264__eval_2El__1120[] = {
  _acc = LONG(0);
  _tmp7 = _acc;
  _acc = _tmp6;
  _acc = ((oop*)_acc)[getLong(_tmp7)];
  _tmp7 = _acc;
  _acc = _tmp1;
  _tmp8 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp7;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__1265__eval_2El__1121[] = {
  _acc = LONG(1);
  _tmp8 = _acc;
  _acc = _tmp6;
  _acc = ((oop*)_acc)[getLong(_tmp8)];
  _tmp6 = _acc;

static long ___L__1263__eval_2El__1119[] = {

static long ___L__1266__eval_2El__1119[] = {
  _acc = _tmp6;
  _tmp8 = _acc;
  _acc = LONG(0);
  _acc = _tmp8;
  if (_acc == nil) goto ___L__1267__eval_2El__1119;
  _acc = LONG(1);
  _tmp7 = _acc;
  _acc = _tmp8;
  _acc = LONG(getLong(_acc) & getLong(_tmp7));
  if (_acc == nil) goto ___L__1269__eval_2El__1119;
  _acc = __3Clong_3E;
  goto ___L__1270__eval_2El__1119;

static long ___L__1269__eval_2El__1119[] = {
  _acc = LONG(-1);
  _tmp7 = _acc;
  _acc = _tmp8;
  _acc = ((oop*)_acc)[getLong(_tmp7)];

static long ___L__1270__eval_2El__1119[] = {
  goto ___L__1268__eval_2El__1119;

static long ___L__1267__eval_2El__1119[] = {
  _acc = __3Cundefined_3E;

static long ___L__1268__eval_2El__1119[] = {
  _tmp8 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp8) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1262__eval_2El__1119;

static long ___L__1271__eval_2El__1122[] = {
  _acc = _tmp2;
  _tmp8 = _acc;
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = LONG(0);
  _acc = LONG(3);
  _tmp9 = _acc;
  _acc = __3Cvariable_3E;
  _tmp10 = _acc;
  _acc = _tmp7;
  _tmp11 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp10;
  _tmp1 = _tmp11;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp9)];
  _tmp7 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp9 = _acc;
  _acc = __3Clong_3E;
  _tmp11 = _acc;
  _acc = _tmp7;
  _tmp10 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp11;
  _tmp1 = _tmp10;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp9)];
  _tmp7 = _acc;
  _acc = _tmp0;
  _tmp9 = _acc;
  _acc = _k__set__array__at;
  _tmp0 = _tmp8;
  _tmp1 = _tmp7;
  _tmp2 = _tmp9;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  goto ___L__1253__eval_2El__1115;

static long ___L__1252__eval_2El__1115[] = {

static long ___L__1253__eval_2El__1115[] = {

static long ___L__1272__eval_2El__1123[] = {
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp1 = _acc;

static long ___L__1249__eval_2El__1113[] = {

static long ___L__1273__eval_2El__1113[] = {
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = _tmp5;
  if (_acc == nil) goto ___L__1274__eval_2El__1113;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp5;
  _acc = LONG(getLong(_acc) & getLong(_tmp6));
  if (_acc == nil) goto ___L__1276__eval_2El__1113;
  _acc = __3Clong_3E;
  goto ___L__1277__eval_2El__1113;

static long ___L__1276__eval_2El__1113[] = {
  _acc = LONG(-1);
  _tmp6 = _acc;
  _acc = _tmp5;
  _acc = ((oop*)_acc)[getLong(_tmp6)];

static long ___L__1277__eval_2El__1113[] = {
  goto ___L__1275__eval_2El__1113;

static long ___L__1274__eval_2El__1113[] = {
  _acc = __3Cundefined_3E;

static long ___L__1275__eval_2El__1113[] = {
  _tmp5 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp5) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1248__eval_2El__1113;

static long ___L__1278__eval_2El__1124[] = {
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__1279__eval_2El__1125[] = {
  goto ___L__1281__eval_2El__1125;

static long ___L__1280__eval_2El__1125[] = {

static long ___L__1282__eval_2El__1126[] = {
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp5 = _acc;
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__1283__eval_2El__1127[] = {
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp3 = _acc;

static long ___L__1281__eval_2El__1125[] = {

static long ___L__1284__eval_2El__1125[] = {
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = LONG(0);
  _acc = _tmp6;
  if (_acc == nil) goto ___L__1285__eval_2El__1125;
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = _tmp6;
  _acc = LONG(getLong(_acc) & getLong(_tmp5));
  if (_acc == nil) goto ___L__1287__eval_2El__1125;
  _acc = __3Clong_3E;
  goto ___L__1288__eval_2El__1125;

static long ___L__1287__eval_2El__1125[] = {
  _acc = LONG(-1);
  _tmp5 = _acc;
  _acc = _tmp6;
  _acc = ((oop*)_acc)[getLong(_tmp5)];

static long ___L__1288__eval_2El__1125[] = {
  goto ___L__1286__eval_2El__1125;

static long ___L__1285__eval_2El__1125[] = {
  _acc = __3Cundefined_3E;

static long ___L__1286__eval_2El__1125[] = {
  _tmp6 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp6) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1280__eval_2El__1125;
  _tmp6 = _acc;

static long ___L__1289__eval_2El__1112[] = {
  _acc = (oop)&_tmp0;
  _tmp5 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp6;
  _acc = _tmp0;
return _acc;
}

oop subr_let = (oop)subr_let;
## defn subr_lambda
oop subr_lambda(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1290__eval_2El__1105[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _new_2D_3Cexpr_3E;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
return _acc;
}

oop subr_lambda = (oop)subr_lambda;
## defn subr_definedP
oop subr_definedP(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1291__eval_2El__1100[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__1292__eval_2El__1101[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc != nil) goto ___L__1293__eval_2El__1101;
  _acc = _globals;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__1293__eval_2El__1101[] = {
  _tmp1 = _acc;

static long ___L__1294__eval_2El__1102[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = _k__env__find__variable;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
return _acc;
}

oop subr_definedP = (oop)subr_definedP;
## defn subr_define
oop subr_define(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1295__eval_2El__1090[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__1296__eval_2El__1091[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__1298__eval_2El__1091;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__1300__eval_2El__1091;
  _acc = __3Clong_3E;
  goto ___L__1301__eval_2El__1091;

static long ___L__1300__eval_2El__1091[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__1301__eval_2El__1091[] = {
  goto ___L__1299__eval_2El__1091;

static long ___L__1298__eval_2El__1091[] = {
  _acc = __3Cundefined_3E;

static long ___L__1299__eval_2El__1091[] = {
  _tmp1 = _acc;
  _acc = __3Cvariable_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1297__eval_2El__1091;

static long ___L__1302__eval_2El__1092[] = {

static long ___L__1303__eval_2El__1093[] = {

static long ___L__1304__eval_2El__1093[] = {
  "\012error: non-variable in define: "
,
    _acc = (oop)___L__1304__eval_2El__1093;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1305__eval_2El__1094[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__dumpln;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1306__eval_2El__1095[] = {

static long ___L__1307__eval_2El__1095[] = {
  "aborting"
,
    _acc = (oop)___L__1307__eval_2El__1095;
  _tmp1 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1297__eval_2El__1091[] = {

static long ___L__1308__eval_2El__1096[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1309__eval_2El__1097[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cvariable_3E;
  _tmp5 = _acc;
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp4)] = _tmp3;
return _acc;
}

oop subr_define = (oop)subr_define;
## defn evlist
oop evlist(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1310__eval_2El__1044[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1313__eval_2El__1044;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1315__eval_2El__1044;
  _acc = __3Clong_3E;
  goto ___L__1316__eval_2El__1044;

static long ___L__1315__eval_2El__1044[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1316__eval_2El__1044[] = {
  goto ___L__1314__eval_2El__1044;

static long ___L__1313__eval_2El__1044[] = {
  _acc = __3Cundefined_3E;

static long ___L__1314__eval_2El__1044[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1311__eval_2El__1044;

static long ___L__1317__eval_2El__1045[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__1318__eval_2El__1046[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1319__eval_2El__1047[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _evlist;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1320__eval_2El__1048[] = {
  _acc = (oop)&_tmp2;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1321__eval_2El__1049[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp0;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp3 = _acc;

static long ___L__1322__eval_2El__1048[] = {
  _acc = (oop)&_tmp2;
  _tmp0 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp3;
  _tmp2 = _acc;

static long ___L__1323__eval_2El__1046[] = {
  _acc = (oop)&_tmp1;
  _tmp3 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp2;
  goto ___L__1312__eval_2El__1044;

static long ___L__1311__eval_2El__1044[] = {
  _acc = _tmp0;

static long ___L__1312__eval_2El__1044[] = {
return _acc;
}

oop evlist = (oop)evlist;
## defn k_encode
oop k_encode(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1324__eval_2El__980[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1327__eval_2El__980;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1329__eval_2El__980;
  _acc = __3Clong_3E;
  goto ___L__1330__eval_2El__980;

static long ___L__1329__eval_2El__980[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1330__eval_2El__980[] = {
  goto ___L__1328__eval_2El__980;

static long ___L__1327__eval_2El__980[] = {
  _acc = __3Cundefined_3E;

static long ___L__1328__eval_2El__980[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1325__eval_2El__980;

static long ___L__1331__eval_2El__981[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _k__encode;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__1332__eval_2El__982[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__1333__eval_2El__983[] = {
  _acc = (oop)&_tmp1;
  _tmp2 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = (oop)&_tmp0;
  _tmp2 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1334__eval_2El__984[] = {

static long ___L__1337__eval_2El__985[] = {
  _acc = _f__let;
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1335__eval_2El__984;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;

static long ___L__1338__eval_2El__986[] = {
  _acc = (oop)&_tmp1;
  _tmp3 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1339__eval_2El__987[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp6 = _acc;
  _acc = __3Cenv_3E;
  _tmp7 = _acc;
  _acc = _tmp5;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Clong_3E;
  _tmp8 = _acc;
  _acc = _tmp5;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp8;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp5 = _acc;
  _acc = _new_2D_3Cenv_3E;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp1 = _acc;

static long ___L__1340__eval_2El__988[] = {
  goto ___L__1342__eval_2El__988;

static long ___L__1341__eval_2El__988[] = {

static long ___L__1343__eval_2El__989[] = {
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp5 = _acc;

static long ___L__1344__eval_2El__990[] = {
  _acc = _tmp5;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = _tmp4;
  if (_acc == nil) goto ___L__1346__eval_2El__990;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp4;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1348__eval_2El__990;
  _acc = __3Clong_3E;
  goto ___L__1349__eval_2El__990;

static long ___L__1348__eval_2El__990[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp4;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1349__eval_2El__990[] = {
  goto ___L__1347__eval_2El__990;

static long ___L__1346__eval_2El__990[] = {
  _acc = __3Cundefined_3E;

static long ___L__1347__eval_2El__990[] = {
  _tmp4 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1345__eval_2El__990;
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = _tmp5;
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp5 = _acc;

static long ___L__1345__eval_2El__990[] = {

static long ___L__1350__eval_2El__991[] = {
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _tmp5;
  _tmp3 = _acc;
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _tmp2 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__1351__eval_2El__992[] = {
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp2 = _acc;

static long ___L__1342__eval_2El__988[] = {

static long ___L__1352__eval_2El__988[] = {
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = _tmp5;
  if (_acc == nil) goto ___L__1353__eval_2El__988;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp5;
  _acc = LONG(getLong(_acc) & getLong(_tmp6));
  if (_acc == nil) goto ___L__1355__eval_2El__988;
  _acc = __3Clong_3E;
  goto ___L__1356__eval_2El__988;

static long ___L__1355__eval_2El__988[] = {
  _acc = LONG(-1);
  _tmp6 = _acc;
  _acc = _tmp5;
  _acc = ((oop*)_acc)[getLong(_tmp6)];

static long ___L__1356__eval_2El__988[] = {
  goto ___L__1354__eval_2El__988;

static long ___L__1353__eval_2El__988[] = {
  _acc = __3Cundefined_3E;

static long ___L__1354__eval_2El__988[] = {
  _tmp5 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp5) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1341__eval_2El__988;

static long ___L__1357__eval_2El__993[] = {
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = _enlist;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__1358__eval_2El__994[] = {
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp6;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  _tmp5 = _acc;

static long ___L__1359__eval_2El__986[] = {
  _acc = (oop)&_tmp1;
  _tmp6 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp5;
  goto ___L__1336__eval_2El__984;

static long ___L__1335__eval_2El__984[] = {

static long ___L__1360__eval_2El__984[] = {

static long ___L__1363__eval_2El__995[] = {
  _acc = _f__lambda;
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1361__eval_2El__984;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;

static long ___L__1364__eval_2El__996[] = {
  _acc = (oop)&_tmp1;
  _tmp5 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1365__eval_2El__997[] = {
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = _new_2D_3Cenv_3E;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp1 = _acc;

static long ___L__1366__eval_2El__998[] = {
  goto ___L__1368__eval_2El__998;

static long ___L__1367__eval_2El__998[] = {

static long ___L__1369__eval_2El__999[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp6 = _acc;
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp3;
  _tmp1 = _tmp6;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__1370__eval_2El__1000[] = {
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp2 = _acc;

static long ___L__1368__eval_2El__998[] = {

static long ___L__1371__eval_2El__998[] = {
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = _tmp5;
  if (_acc == nil) goto ___L__1372__eval_2El__998;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp5;
  _acc = LONG(getLong(_acc) & getLong(_tmp6));
  if (_acc == nil) goto ___L__1374__eval_2El__998;
  _acc = __3Clong_3E;
  goto ___L__1375__eval_2El__998;

static long ___L__1374__eval_2El__998[] = {
  _acc = LONG(-1);
  _tmp6 = _acc;
  _acc = _tmp5;
  _acc = ((oop*)_acc)[getLong(_tmp6)];

static long ___L__1375__eval_2El__998[] = {
  goto ___L__1373__eval_2El__998;

static long ___L__1372__eval_2El__998[] = {
  _acc = __3Cundefined_3E;

static long ___L__1373__eval_2El__998[] = {
  _tmp5 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp5) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1367__eval_2El__998;

static long ___L__1376__eval_2El__1001[] = {
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1377__eval_2El__1001;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp6 = _acc;
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__1377__eval_2El__1001[] = {

static long ___L__1378__eval_2El__1002[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = _enlist;
  _tmp0 = _tmp3;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__1379__eval_2El__1003[] = {
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp6;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  _tmp3 = _acc;

static long ___L__1380__eval_2El__996[] = {
  _acc = (oop)&_tmp1;
  _tmp6 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp3;
  goto ___L__1362__eval_2El__984;

static long ___L__1361__eval_2El__984[] = {

static long ___L__1381__eval_2El__984[] = {

static long ___L__1384__eval_2El__1004[] = {
  _acc = _f__define;
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1382__eval_2El__984;
  _acc = _globals;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = __3Cvariable_3E;
  _tmp6 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp3 = _acc;
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = _k__env__define;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp5 = _acc;

static long ___L__1385__eval_2El__1005[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _k__cdr;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _enlist;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__1386__eval_2El__1006[] = {
  _acc = _tmp5;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  goto ___L__1383__eval_2El__984;

static long ___L__1382__eval_2El__984[] = {

static long ___L__1387__eval_2El__984[] = {

static long ___L__1390__eval_2El__1007[] = {
  _acc = _f__set;
  _tmp5 = _acc;
  _acc = _tmp1;
  _acc = (_acc == _tmp5) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1388__eval_2El__984;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp3 = _acc;
  _acc = _k__env__find__variable;
  _tmp0 = _tmp5;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp3 = _acc;

static long ___L__1391__eval_2El__1008[] = {
  _acc = _tmp3;
  if (_acc != nil) goto ___L__1392__eval_2El__1008;

static long ___L__1393__eval_2El__1008[] = {
  "set: undefined variable: %s"
,
    _acc = (oop)___L__1393__eval_2El__1008;
  _tmp5 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Csymbol_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp2 = _acc;
  _acc = _fatal1;
  _tmp0 = _tmp5;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1392__eval_2El__1008[] = {

static long ___L__1394__eval_2El__1009[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__cdr;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _enlist;
  _tmp0 = _tmp2;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__1395__eval_2El__1010[] = {
  _acc = _tmp3;
  _tmp5 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp5;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  goto ___L__1389__eval_2El__984;

static long ___L__1388__eval_2El__984[] = {

static long ___L__1396__eval_2El__984[] = {

static long ___L__1399__eval_2El__1011[] = {
  _acc = _f__quote;
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = (_acc != _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1397__eval_2El__984;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _enlist;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  goto ___L__1398__eval_2El__984;

static long ___L__1397__eval_2El__984[] = {
  _acc = LONG(0);

static long ___L__1398__eval_2El__984[] = {

static long ___L__1389__eval_2El__984[] = {

static long ___L__1383__eval_2El__984[] = {

static long ___L__1362__eval_2El__984[] = {

static long ___L__1336__eval_2El__984[] = {

static long ___L__1400__eval_2El__1012[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  _tmp3 = _acc;

static long ___L__1401__eval_2El__983[] = {
  _acc = (oop)&_tmp0;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = (oop)&_tmp1;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp3;
  goto ___L__1326__eval_2El__980;

static long ___L__1325__eval_2El__980[] = {

static long ___L__1402__eval_2El__1013[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1405__eval_2El__1013;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1407__eval_2El__1013;
  _acc = __3Clong_3E;
  goto ___L__1408__eval_2El__1013;

static long ___L__1407__eval_2El__1013[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1408__eval_2El__1013[] = {
  goto ___L__1406__eval_2El__1013;

static long ___L__1405__eval_2El__1013[] = {
  _acc = __3Cundefined_3E;

static long ___L__1406__eval_2El__1013[] = {
  _tmp0 = _acc;
  _acc = __3Csymbol_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1403__eval_2El__1013;

static long ___L__1409__eval_2El__1014[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__env__find__variable;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__1410__eval_2El__1015[] = {
  _acc = _tmp1;
  if (_acc != nil) goto ___L__1411__eval_2El__1015;

static long ___L__1412__eval_2El__1015[] = {
  "undefined variable: %s"
,
    _acc = (oop)___L__1412__eval_2El__1015;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Csymbol_3E;
  _tmp5 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp3 = _acc;
  _acc = _fatal1;
  _tmp0 = _tmp0;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1411__eval_2El__1015[] = {

static long ___L__1413__eval_2El__1016[] = {
  _acc = _tmp1;
  _tmp0 = _acc;

static long ___L__1414__eval_2El__1017[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _is__global;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__1415__eval_2El__1017;

static long ___L__1417__eval_2El__1018[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = __3Cvariable_3E;
  _tmp2 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp3 = _acc;

static long ___L__1418__eval_2El__1019[] = {
  _acc = _tmp3;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1421__eval_2El__1019;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp6));
  if (_acc == nil) goto ___L__1423__eval_2El__1019;
  _acc = __3Clong_3E;
  goto ___L__1424__eval_2El__1019;

static long ___L__1423__eval_2El__1019[] = {
  _acc = LONG(-1);
  _tmp6 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp6)];

static long ___L__1424__eval_2El__1019[] = {
  goto ___L__1422__eval_2El__1019;

static long ___L__1421__eval_2El__1019[] = {
  _acc = __3Cundefined_3E;

static long ___L__1422__eval_2El__1019[] = {
  _tmp0 = _acc;
  _acc = __3Cform_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1420__eval_2El__1019;
  _acc = _tmp3;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1425__eval_2El__1019;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp6));
  if (_acc == nil) goto ___L__1427__eval_2El__1019;
  _acc = __3Clong_3E;
  goto ___L__1428__eval_2El__1019;

static long ___L__1427__eval_2El__1019[] = {
  _acc = LONG(-1);
  _tmp6 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp6)];

static long ___L__1428__eval_2El__1019[] = {
  goto ___L__1426__eval_2El__1019;

static long ___L__1425__eval_2El__1019[] = {
  _acc = __3Cundefined_3E;

static long ___L__1426__eval_2El__1019[] = {
  _tmp0 = _acc;
  _acc = __3Cfixed_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);

static long ___L__1420__eval_2El__1019[] = {
  if (_acc == nil) goto ___L__1419__eval_2El__1019;

static long ___L__1429__eval_2El__1020[] = {
  _acc = _tmp3;
  _tmp0 = _acc;

static long ___L__1419__eval_2El__1019[] = {
  goto ___L__1416__eval_2El__1017;

static long ___L__1415__eval_2El__1017[] = {

static long ___L__1430__eval_2El__1021[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp0 = _acc;
  _acc = __3Cvariable_3E;
  _tmp6 = _acc;
  _acc = _tmp3;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp3 = _acc;

static long ___L__1431__eval_2El__1022[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cenv_3E;
  _tmp6 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _tmp5 = _acc;
  _acc = _tmp0;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp0 = _acc;
  _acc = _tmp3;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = __3Cenv_3E;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Clong_3E;
  _tmp7 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1432__eval_2El__1022;

static long ___L__1433__eval_2El__1023[] = {
  _acc = _tmp3;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _s__t;
  _tmp2 = _acc;
  _acc = LONG(4);
  _tmp6 = _acc;
  _acc = __3Cenv_3E;
  _tmp5 = _acc;
  _acc = _tmp0;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp6)] = _tmp2;

static long ___L__1432__eval_2El__1022[] = {

static long ___L__1416__eval_2El__1017[] = {
  goto ___L__1404__eval_2El__1013;

static long ___L__1403__eval_2El__1013[] = {

static long ___L__1434__eval_2El__1024[] = {
  _acc = _encoders;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = __3Cvariable_3E;
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__1435__eval_2El__1024;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__1437__eval_2El__1024;
  _acc = __3Clong_3E;
  goto ___L__1438__eval_2El__1024;

static long ___L__1437__eval_2El__1024[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__1438__eval_2El__1024[] = {
  goto ___L__1436__eval_2El__1024;

static long ___L__1435__eval_2El__1024[] = {
  _acc = __3Cundefined_3E;

static long ___L__1436__eval_2El__1024[] = {
  _tmp3 = _acc;
  _acc = _k__array__at;
  _tmp0 = _tmp1;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp3 = _acc;

static long ___L__1439__eval_2El__1025[] = {
  _acc = _tmp3;
  if (_acc == nil) goto ___L__1440__eval_2El__1025;

static long ___L__1441__eval_2El__1025[] = {
  "APPLY GOT ENCODER\012... "
,
    _acc = (oop)___L__1441__eval_2El__1025;
  _tmp1 = _acc;
  _acc = _tmp3;
  _tmp2 = _acc;
  _acc = _k__println;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _tmp2 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__1440__eval_2El__1025[] = {

static long ___L__1442__eval_2El__1026[] = {
  _acc = _tmp3;
  if (_acc == nil) goto ___L__1443__eval_2El__1026;

static long ___L__1444__eval_2El__1027[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1445__eval_2El__1028[] = {
  _acc = (oop)&_tmp2;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1446__eval_2El__1029[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _tmp2;
  _tmp1 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1447__eval_2El__1030[] = {

static long ___L__1448__eval_2El__1030[] = {
  "APPLY ENCODER\012... "
,
    _acc = (oop)___L__1448__eval_2El__1030;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp3;
  _tmp1 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1449__eval_2El__1030[] = {
  " "
,
    _acc = (oop)___L__1449__eval_2El__1030;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp2;
  _tmp1 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1450__eval_2El__1030[] = {
  " "
,
    _acc = (oop)___L__1450__eval_2El__1030;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _k__println;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1451__eval_2El__1031[] = {
  _acc = _tmp3;
  _tmp1 = _acc;
  _acc = _tmp2;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = _k__apply;
  _tmp0 = _tmp1;
  _tmp1 = _tmp0;
  _tmp2 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp0 = _acc;
  _tmp6 = _acc;

static long ___L__1452__eval_2El__1028[] = {
  _acc = (oop)&_tmp2;
  _tmp0 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp6;

static long ___L__1443__eval_2El__1026[] = {

static long ___L__1404__eval_2El__1013[] = {

static long ___L__1326__eval_2El__980[] = {
  _acc = _tmp0;
return _acc;
}

oop k_encode = (oop)k_encode;
## defn enlist
oop enlist(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1453__eval_2El__1035[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1456__eval_2El__1035;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1458__eval_2El__1035;
  _acc = __3Clong_3E;
  goto ___L__1459__eval_2El__1035;

static long ___L__1458__eval_2El__1035[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1459__eval_2El__1035[] = {
  goto ___L__1457__eval_2El__1035;

static long ___L__1456__eval_2El__1035[] = {
  _acc = __3Cundefined_3E;

static long ___L__1457__eval_2El__1035[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1454__eval_2El__1035;

static long ___L__1460__eval_2El__1036[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _k__encode;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__1461__eval_2El__1037[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1462__eval_2El__1038[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _enlist;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1463__eval_2El__1039[] = {
  _acc = (oop)&_tmp2;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1464__eval_2El__1040[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp0;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp3 = _acc;

static long ___L__1465__eval_2El__1039[] = {
  _acc = (oop)&_tmp2;
  _tmp0 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp3;
  _tmp2 = _acc;

static long ___L__1466__eval_2El__1037[] = {
  _acc = (oop)&_tmp1;
  _tmp3 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp2;
  goto ___L__1455__eval_2El__1035;

static long ___L__1454__eval_2El__1035[] = {

static long ___L__1467__eval_2El__1041[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__encode;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1455__eval_2El__1035[] = {
return _acc;
}

oop enlist = (oop)enlist;
## defn k_expand
oop k_expand(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1468__eval_2El__921[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1471__eval_2El__921;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1473__eval_2El__921;
  _acc = __3Clong_3E;
  goto ___L__1474__eval_2El__921;

static long ___L__1473__eval_2El__921[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1474__eval_2El__921[] = {
  goto ___L__1472__eval_2El__921;

static long ___L__1471__eval_2El__921[] = {
  _acc = __3Cundefined_3E;

static long ___L__1472__eval_2El__921[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1469__eval_2El__921;

static long ___L__1475__eval_2El__922[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _k__expand;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__1476__eval_2El__923[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1477__eval_2El__924[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1480__eval_2El__924;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__1482__eval_2El__924;
  _acc = __3Clong_3E;
  goto ___L__1483__eval_2El__924;

static long ___L__1482__eval_2El__924[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__1483__eval_2El__924[] = {
  goto ___L__1481__eval_2El__924;

static long ___L__1480__eval_2El__924[] = {
  _acc = __3Cundefined_3E;

static long ___L__1481__eval_2El__924[] = {
  _tmp0 = _acc;
  _acc = __3Csymbol_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1478__eval_2El__924;

static long ___L__1484__eval_2El__925[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__env__find__variable;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1485__eval_2El__926[] = {
  _acc = _tmp2;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1487__eval_2El__926;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1489__eval_2El__926;
  _acc = __3Clong_3E;
  goto ___L__1490__eval_2El__926;

static long ___L__1489__eval_2El__926[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1490__eval_2El__926[] = {
  goto ___L__1488__eval_2El__926;

static long ___L__1487__eval_2El__926[] = {
  _acc = __3Cundefined_3E;

static long ___L__1488__eval_2El__926[] = {
  _tmp0 = _acc;
  _acc = __3Cvariable_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1486__eval_2El__926;
  _acc = _tmp2;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = __3Cvariable_3E;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;

static long ___L__1486__eval_2El__926[] = {

static long ___L__1491__eval_2El__927[] = {
  _acc = _tmp2;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1493__eval_2El__927;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc == nil) goto ___L__1495__eval_2El__927;
  _acc = __3Clong_3E;
  goto ___L__1496__eval_2El__927;

static long ___L__1495__eval_2El__927[] = {
  _acc = LONG(-1);
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__1496__eval_2El__927[] = {
  goto ___L__1494__eval_2El__927;

static long ___L__1493__eval_2El__927[] = {
  _acc = __3Cundefined_3E;

static long ___L__1494__eval_2El__927[] = {
  _tmp0 = _acc;
  _acc = __3Cform_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1492__eval_2El__927;

static long ___L__1497__eval_2El__928[] = {
  _acc = _tmp2;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Cform_3E;
  _tmp5 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp0 = _acc;

static long ___L__1498__eval_2El__929[] = {
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1499__eval_2El__929;

static long ___L__1500__eval_2El__930[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp4 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp4 = _acc;

static long ___L__1501__eval_2El__931[] = {
  _acc = (oop)&_tmp4;
  _tmp3 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1502__eval_2El__932[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _tmp4;
  _tmp5 = _acc;
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = _k__apply;
  _tmp0 = _tmp3;
  _tmp1 = _tmp5;
  _tmp2 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp1 = _acc;

static long ___L__1503__eval_2El__933[] = {
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _k__expand;
  _tmp0 = _tmp6;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;
  _tmp5 = _acc;

static long ___L__1504__eval_2El__931[] = {
  _acc = (oop)&_tmp4;
  _tmp6 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp5;

static long ___L__1505__eval_2El__934[] = {
  _acc = (oop)&_tmp1;
  _tmp5 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1506__eval_2El__935[] = {
  _acc = _tmp1;
  goto ___L__1507__eval_2El__935;

static long ___L__1499__eval_2El__929[] = {

static long ___L__1492__eval_2El__927[] = {
  goto ___L__1479__eval_2El__924;

static long ___L__1478__eval_2El__924[] = {

static long ___L__1479__eval_2El__924[] = {

static long ___L__1508__eval_2El__936[] = {
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;

static long ___L__1509__eval_2El__937[] = {
  _acc = (oop)&_tmp2;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1510__eval_2El__938[] = {
  _acc = _s__quote;
  _tmp0 = _acc;
  _acc = _tmp1;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1511__eval_2El__938;
  _acc = _tmp2;
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _exlist;
  _tmp0 = _tmp0;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1511__eval_2El__938[] = {

static long ___L__1512__eval_2El__939[] = {
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _s__set;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1513__eval_2El__939;

static long ___L__1514__eval_2El__940[] = {
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = _tmp4;
  if (_acc == nil) goto ___L__1515__eval_2El__940;
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp4;
  _acc = LONG(getLong(_acc) & getLong(_tmp0));
  if (_acc == nil) goto ___L__1517__eval_2El__940;
  _acc = __3Clong_3E;
  goto ___L__1518__eval_2El__940;

static long ___L__1517__eval_2El__940[] = {
  _acc = LONG(-1);
  _tmp0 = _acc;
  _acc = _tmp4;
  _acc = ((oop*)_acc)[getLong(_tmp0)];

static long ___L__1518__eval_2El__940[] = {
  goto ___L__1516__eval_2El__940;

static long ___L__1515__eval_2El__940[] = {
  _acc = __3Cundefined_3E;

static long ___L__1516__eval_2El__940[] = {
  _tmp4 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1513__eval_2El__939;

static long ___L__1519__eval_2El__941[] = {
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = _k__caar;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = _tmp4;
  if (_acc == nil) goto ___L__1520__eval_2El__941;
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp4;
  _acc = LONG(getLong(_acc) & getLong(_tmp0));
  if (_acc == nil) goto ___L__1522__eval_2El__941;
  _acc = __3Clong_3E;
  goto ___L__1523__eval_2El__941;

static long ___L__1522__eval_2El__941[] = {
  _acc = LONG(-1);
  _tmp0 = _acc;
  _acc = _tmp4;
  _acc = ((oop*)_acc)[getLong(_tmp0)];

static long ___L__1523__eval_2El__941[] = {
  goto ___L__1521__eval_2El__941;

static long ___L__1520__eval_2El__941[] = {
  _acc = __3Cundefined_3E;

static long ___L__1521__eval_2El__941[] = {
  _tmp4 = _acc;
  _acc = __3Csymbol_3E;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1513__eval_2El__939;

static long ___L__1524__eval_2El__942[] = {
  _acc = _new__buffer;
  _acc = ((oop (*)())_acc)();
  _tmp4 = _acc;

static long ___L__1525__eval_2El__943[] = {
  _acc = _tmp4;
  _tmp0 = _acc;

static long ___L__1526__eval_2El__943[] = {
  "set-"
,
    _acc = (oop)___L__1526__eval_2El__943;
  _tmp5 = _acc;
  _acc = _buffer__append__all;
  _tmp0 = _tmp0;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1527__eval_2El__944[] = {
  _acc = _tmp4;
  _tmp5 = _acc;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Csymbol_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp0 = _acc;
  _acc = _buffer__append__all;
  _tmp0 = _tmp5;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1528__eval_2El__945[] = {
  _acc = _tmp4;
  _tmp0 = _acc;
  _acc = _buffer__contents;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _intern;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__1529__eval_2El__946[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp5 = _acc;
  _acc = _k__concat;
  _tmp0 = _tmp0;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1513__eval_2El__939[] = {

static long ___L__1530__eval_2El__947[] = {
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__1531__eval_2El__948[] = {
  _acc = (oop)&_tmp2;
  _tmp5 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1532__eval_2El__949[] = {
  _acc = (oop)&_tmp1;
  _tmp5 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__1470__eval_2El__921;

static long ___L__1469__eval_2El__921[] = {

static long ___L__1533__eval_2El__950[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__1536__eval_2El__950;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__1538__eval_2El__950;
  _acc = __3Clong_3E;
  goto ___L__1539__eval_2El__950;

static long ___L__1538__eval_2El__950[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__1539__eval_2El__950[] = {
  goto ___L__1537__eval_2El__950;

static long ___L__1536__eval_2El__950[] = {
  _acc = __3Cundefined_3E;

static long ___L__1537__eval_2El__950[] = {
  _tmp1 = _acc;
  _acc = __3Csymbol_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1534__eval_2El__950;

static long ___L__1540__eval_2El__951[] = {
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__env__find__variable;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1541__eval_2El__952[] = {
  _acc = _tmp2;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__1543__eval_2El__952;
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp5));
  if (_acc == nil) goto ___L__1545__eval_2El__952;
  _acc = __3Clong_3E;
  goto ___L__1546__eval_2El__952;

static long ___L__1545__eval_2El__952[] = {
  _acc = LONG(-1);
  _tmp5 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp5)];

static long ___L__1546__eval_2El__952[] = {
  goto ___L__1544__eval_2El__952;

static long ___L__1543__eval_2El__952[] = {
  _acc = __3Cundefined_3E;

static long ___L__1544__eval_2El__952[] = {
  _tmp1 = _acc;
  _acc = __3Cvariable_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1542__eval_2El__952;
  _acc = _tmp2;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = __3Cvariable_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp2 = _acc;

static long ___L__1542__eval_2El__952[] = {

static long ___L__1547__eval_2El__953[] = {
  _acc = _tmp2;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__1549__eval_2El__953;
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp5));
  if (_acc == nil) goto ___L__1551__eval_2El__953;
  _acc = __3Clong_3E;
  goto ___L__1552__eval_2El__953;

static long ___L__1551__eval_2El__953[] = {
  _acc = LONG(-1);
  _tmp5 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp5)];

static long ___L__1552__eval_2El__953[] = {
  goto ___L__1550__eval_2El__953;

static long ___L__1549__eval_2El__953[] = {
  _acc = __3Cundefined_3E;

static long ___L__1550__eval_2El__953[] = {
  _tmp1 = _acc;
  _acc = __3Cform_3E;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1548__eval_2El__953;

static long ___L__1553__eval_2El__954[] = {
  _acc = _tmp2;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = __3Cform_3E;
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp0;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp1 = _acc;

static long ___L__1554__eval_2El__955[] = {
  _acc = _tmp1;
  if (_acc == nil) goto ___L__1555__eval_2El__955;

static long ___L__1556__eval_2El__956[] = {
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp5;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp4 = _acc;

static long ___L__1557__eval_2El__957[] = {
  _acc = (oop)&_tmp4;
  _tmp5 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1558__eval_2El__958[] = {
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _tmp4;
  _tmp0 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp5;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp4 = _acc;

static long ___L__1559__eval_2El__959[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _tmp4;
  _tmp5 = _acc;
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = _k__apply;
  _tmp0 = _tmp0;
  _tmp1 = _tmp5;
  _tmp2 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp4 = _acc;

static long ___L__1560__eval_2El__960[] = {
  _acc = _tmp4;
  _tmp6 = _acc;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _k__expand;
  _tmp0 = _tmp6;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  _tmp5 = _acc;

static long ___L__1561__eval_2El__957[] = {
  _acc = (oop)&_tmp4;
  _tmp6 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp5;

static long ___L__1555__eval_2El__955[] = {

static long ___L__1548__eval_2El__953[] = {
  goto ___L__1535__eval_2El__950;

static long ___L__1534__eval_2El__950[] = {

static long ___L__1562__eval_2El__961[] = {
  _acc = _expanders;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = __3Cvariable_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  if (_acc == nil) goto ___L__1563__eval_2El__961;
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp5));
  if (_acc == nil) goto ___L__1565__eval_2El__961;
  _acc = __3Clong_3E;
  goto ___L__1566__eval_2El__961;

static long ___L__1565__eval_2El__961[] = {
  _acc = LONG(-1);
  _tmp5 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp5)];

static long ___L__1566__eval_2El__961[] = {
  goto ___L__1564__eval_2El__961;

static long ___L__1563__eval_2El__961[] = {
  _acc = __3Cundefined_3E;

static long ___L__1564__eval_2El__961[] = {
  _tmp1 = _acc;
  _acc = _k__array__at;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__1567__eval_2El__962[] = {
  _acc = _tmp1;
  if (_acc == nil) goto ___L__1568__eval_2El__962;

static long ___L__1569__eval_2El__963[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp2;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp5 = _acc;

static long ___L__1570__eval_2El__964[] = {
  _acc = (oop)&_tmp5;
  _tmp2 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1571__eval_2El__965[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _tmp5;
  _tmp4 = _acc;
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = _k__apply;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _tmp2 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp0 = _acc;
  _tmp6 = _acc;

static long ___L__1572__eval_2El__964[] = {
  _acc = (oop)&_tmp5;
  _tmp4 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp6;

static long ___L__1568__eval_2El__962[] = {

static long ___L__1535__eval_2El__950[] = {

static long ___L__1470__eval_2El__921[] = {
  _acc = _tmp0;
___L__1507__eval_2El__935:
  return _acc;
}

oop k_expand = (oop)k_expand;
## defn exlist
oop exlist(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1573__eval_2El__969[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1576__eval_2El__969;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1578__eval_2El__969;
  _acc = __3Clong_3E;
  goto ___L__1579__eval_2El__969;

static long ___L__1578__eval_2El__969[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1579__eval_2El__969[] = {
  goto ___L__1577__eval_2El__969;

static long ___L__1576__eval_2El__969[] = {
  _acc = __3Cundefined_3E;

static long ___L__1577__eval_2El__969[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1574__eval_2El__969;

static long ___L__1580__eval_2El__970[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _k__expand;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__1581__eval_2El__971[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1582__eval_2El__972[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _exlist;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1583__eval_2El__973[] = {
  _acc = (oop)&_tmp2;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1584__eval_2El__974[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp0;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp3 = _acc;

static long ___L__1585__eval_2El__973[] = {
  _acc = (oop)&_tmp2;
  _tmp0 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp3;
  _tmp2 = _acc;

static long ___L__1586__eval_2El__971[] = {
  _acc = (oop)&_tmp1;
  _tmp3 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp2;
  goto ___L__1575__eval_2El__969;

static long ___L__1574__eval_2El__969[] = {

static long ___L__1587__eval_2El__975[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__expand;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1575__eval_2El__969[] = {
return _acc;
}

oop exlist = (oop)exlist;
## defn k_apply
oop k_apply(oop _param0, oop _param1, oop _param2) {
  oop _acc = nil;

static long ___L__1588__eval_2El__903[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1589__eval_2El__903;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1591__eval_2El__903;
  _acc = __3Clong_3E;
  goto ___L__1592__eval_2El__903;

static long ___L__1591__eval_2El__903[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1592__eval_2El__903[] = {
  goto ___L__1590__eval_2El__903;

static long ___L__1589__eval_2El__903[] = {
  _acc = __3Cundefined_3E;

static long ___L__1590__eval_2El__903[] = {
  _tmp0 = _acc;

static long ___L__1593__eval_2El__904[] = {

static long ___L__1596__eval_2El__905[] = {
  _acc = __3Cexpr_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1594__eval_2El__904;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = _k__apply__expr;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  goto ___L__1595__eval_2El__904;

static long ___L__1594__eval_2El__904[] = {

static long ___L__1597__eval_2El__904[] = {

static long ___L__1600__eval_2El__906[] = {
  _acc = __3Cfixed_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1598__eval_2El__904;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cfixed_3E;
  _tmp1 = _acc;
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = _k__apply;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _tmp2 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  goto ___L__1599__eval_2El__904;

static long ___L__1598__eval_2El__904[] = {

static long ___L__1601__eval_2El__904[] = {

static long ___L__1604__eval_2El__907[] = {
  _acc = __3Csubr_3E;
  _tmp4 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1602__eval_2El__904;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = __3Csubr_3E;
  _tmp5 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp2 = _tmp5;
  _tmp3 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp0 = _tmp4;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__1603__eval_2El__904;

static long ___L__1602__eval_2El__904[] = {

static long ___L__1605__eval_2El__908[] = {
  _acc = _applicators;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp2;
  _tmp1 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = _tmp4;
  if (_acc == nil) goto ___L__1606__eval_2El__908;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp4;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1608__eval_2El__908;
  _acc = __3Clong_3E;
  goto ___L__1609__eval_2El__908;

static long ___L__1608__eval_2El__908[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp4;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1609__eval_2El__908[] = {
  goto ___L__1607__eval_2El__908;

static long ___L__1606__eval_2El__908[] = {
  _acc = __3Cundefined_3E;

static long ___L__1607__eval_2El__908[] = {
  _tmp4 = _acc;
  _acc = _k__array__at;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp4 = _acc;

static long ___L__1610__eval_2El__909[] = {
  _acc = _tmp4;
  if (_acc == nil) goto ___L__1611__eval_2El__909;

static long ___L__1613__eval_2El__910[] = {
  _acc = _tmp1;
  _tmp2 = _acc;

static long ___L__1614__eval_2El__911[] = {
  _acc = (oop)&_tmp2;
  _tmp1 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1615__eval_2El__912[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp1;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1616__eval_2El__913[] = {
  _acc = _tmp4;
  _tmp3 = _acc;
  _acc = _tmp2;
  _tmp1 = _acc;
  _acc = _tmp2;
  _tmp6 = _acc;
  _acc = _k__apply;
  _tmp0 = _tmp3;
  _tmp1 = _tmp1;
  _tmp2 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp6 = _acc;

static long ___L__1617__eval_2El__911[] = {
  _acc = (oop)&_tmp2;
  _tmp1 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp6;
  goto ___L__1612__eval_2El__909;

static long ___L__1611__eval_2El__909[] = {

static long ___L__1618__eval_2El__914[] = {

static long ___L__1619__eval_2El__914[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__1619__eval_2El__914;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1620__eval_2El__914[] = {
  "cannot apply: "
,
    _acc = (oop)___L__1620__eval_2El__914;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1621__eval_2El__914[] = {
  "\012"
,
    _acc = (oop)___L__1621__eval_2El__914;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__1612__eval_2El__909[] = {

static long ___L__1603__eval_2El__904[] = {

static long ___L__1599__eval_2El__904[] = {

static long ___L__1595__eval_2El__904[] = {
return _acc;
}

oop k_apply = (oop)k_apply;
## defn counter
oop counter = LONG(0);

## defn k_apply_expr
oop k_apply_expr(oop _param0, oop _param1, oop _param2) {
  oop _acc = nil;

static long ___L__1622__eval_2El__874[] = {
  _acc = _opt__verbose;
  _tmp0 = _acc;
  _acc = LONG(2);
  _acc = (getLong(_acc) < getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1623__eval_2El__874;

static long ___L__1624__eval_2El__874[] = {
  "  A  "
,
    _acc = (oop)___L__1624__eval_2El__874;
  _tmp0 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__dump;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1625__eval_2El__874[] = {
  " "
,
    _acc = (oop)___L__1625__eval_2El__874;
  _tmp0 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _k__dump;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1626__eval_2El__874[] = {
  " "
,
    _acc = (oop)___L__1626__eval_2El__874;
  _tmp0 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp2;
  _tmp0 = _acc;
  _acc = _k__dumpln;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _stdout;
  _tmp0 = _acc;
  _acc = _fflush_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1623__eval_2El__874[] = {

static long ___L__1627__eval_2El__875[] = {
  _acc = _tmp1;
  _tmp0 = _acc;

static long ___L__1628__eval_2El__876[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cexpr_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp1 = _acc;

static long ___L__1629__eval_2El__875[] = {

static long ___L__1630__eval_2El__877[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;

static long ___L__1631__eval_2El__875[] = {

static long ___L__1632__eval_2El__878[] = {
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _k__cadr;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp4 = _acc;

static long ___L__1633__eval_2El__879[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp5 = _acc;
  _acc = __3Cexpr_3E;
  _tmp6 = _acc;
  _acc = _tmp3;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp3 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp7 = _acc;
  _acc = _new_2D_3Ccontext_3E;
  _tmp0 = _tmp3;
  _tmp1 = _tmp5;
  _tmp2 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp2 = _acc;

static long ___L__1634__eval_2El__880[] = {
  _acc = _tmp2;
  _tmp7 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp5 = _acc;
  _acc = __3Ccontext_3E;
  _tmp3 = _acc;
  _acc = _tmp7;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp7 = _acc;

static long ___L__1635__eval_2El__881[] = {
  _acc = (oop)&_tmp1;
  _tmp5 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = (oop)&_tmp2;
  _tmp5 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1636__eval_2El__882[] = {
  goto ___L__1638__eval_2El__882;

static long ___L__1637__eval_2El__882[] = {

static long ___L__1639__eval_2El__883[] = {
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = _tmp5;
  if (_acc == nil) goto ___L__1641__eval_2El__883;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp5;
  _acc = LONG(getLong(_acc) & getLong(_tmp6));
  if (_acc == nil) goto ___L__1643__eval_2El__883;
  _acc = __3Clong_3E;
  goto ___L__1644__eval_2El__883;

static long ___L__1643__eval_2El__883[] = {
  _acc = LONG(-1);
  _tmp6 = _acc;
  _acc = _tmp5;
  _acc = ((oop*)_acc)[getLong(_tmp6)];

static long ___L__1644__eval_2El__883[] = {
  goto ___L__1642__eval_2El__883;

static long ___L__1641__eval_2El__883[] = {
  _acc = __3Cundefined_3E;

static long ___L__1642__eval_2El__883[] = {
  _tmp5 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp5) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1640__eval_2El__883;

static long ___L__1645__eval_2El__883[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__1645__eval_2El__883;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1646__eval_2El__883[] = {
  "too few arguments: ("
,
    _acc = (oop)___L__1646__eval_2El__883;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1647__eval_2El__883[] = {
  " "
,
    _acc = (oop)___L__1647__eval_2El__883;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1648__eval_2El__883[] = {
  ")"
,
    _acc = (oop)___L__1648__eval_2El__883;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1649__eval_2El__883[] = {
  "\012"
,
    _acc = (oop)___L__1649__eval_2El__883;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__1640__eval_2El__883[] = {

static long ___L__1650__eval_2El__884[] = {
  _acc = _tmp7;
  _tmp5 = _acc;
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = _tmp4;
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp6 = _acc;
  _acc = LONG(0);
  _acc = LONG(3);
  _tmp3 = _acc;
  _acc = __3Cvariable_3E;
  _tmp8 = _acc;
  _acc = _tmp6;
  _tmp9 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp8;
  _tmp1 = _tmp9;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp6 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp9 = _acc;
  _acc = _tmp6;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp9;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp6 = _acc;
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp3 = _acc;
  _acc = _k__set__array__at;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__1651__eval_2El__885[] = {
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp4;
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp4 = _acc;

static long ___L__1652__eval_2El__886[] = {
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp0 = _acc;

static long ___L__1638__eval_2El__882[] = {

static long ___L__1653__eval_2El__882[] = {
  _acc = _tmp4;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__1654__eval_2El__882;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp6));
  if (_acc == nil) goto ___L__1656__eval_2El__882;
  _acc = __3Clong_3E;
  goto ___L__1657__eval_2El__882;

static long ___L__1656__eval_2El__882[] = {
  _acc = LONG(-1);
  _tmp6 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp6)];

static long ___L__1657__eval_2El__882[] = {
  goto ___L__1655__eval_2El__882;

static long ___L__1654__eval_2El__882[] = {
  _acc = __3Cundefined_3E;

static long ___L__1655__eval_2El__882[] = {
  _tmp3 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1637__eval_2El__882;

static long ___L__1658__eval_2El__887[] = {
  _acc = _tmp4;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp3;
  if (_acc == nil) goto ___L__1660__eval_2El__887;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) & getLong(_tmp6));
  if (_acc == nil) goto ___L__1662__eval_2El__887;
  _acc = __3Clong_3E;
  goto ___L__1663__eval_2El__887;

static long ___L__1662__eval_2El__887[] = {
  _acc = LONG(-1);
  _tmp6 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp6)];

static long ___L__1663__eval_2El__887[] = {
  goto ___L__1661__eval_2El__887;

static long ___L__1660__eval_2El__887[] = {
  _acc = __3Cundefined_3E;

static long ___L__1661__eval_2El__887[] = {
  _tmp3 = _acc;
  _acc = __3Cvariable_3E;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1659__eval_2El__887;

static long ___L__1664__eval_2El__888[] = {

static long ___L__1665__eval_2El__889[] = {
  _acc = _tmp7;
  _tmp3 = _acc;
  _acc = _tmp4;
  _tmp6 = _acc;
  _acc = LONG(0);
  _acc = LONG(3);
  _tmp5 = _acc;
  _acc = __3Cvariable_3E;
  _tmp8 = _acc;
  _acc = _tmp6;
  _tmp9 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp8;
  _tmp1 = _tmp9;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp6 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp9 = _acc;
  _acc = _tmp6;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp9;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp6 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _k__set__array__at;
  _tmp0 = _tmp3;
  _tmp1 = _tmp6;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__1666__eval_2El__890[] = {
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__1659__eval_2El__887[] = {

static long ___L__1667__eval_2El__891[] = {
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1668__eval_2El__891;

static long ___L__1669__eval_2El__891[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__1669__eval_2El__891;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1670__eval_2El__891[] = {
  "too many arguments: ("
,
    _acc = (oop)___L__1670__eval_2El__891;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1671__eval_2El__891[] = {
  " "
,
    _acc = (oop)___L__1671__eval_2El__891;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _k__print;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1672__eval_2El__891[] = {
  ")"
,
    _acc = (oop)___L__1672__eval_2El__891;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1673__eval_2El__891[] = {
  "\012"
,
    _acc = (oop)___L__1673__eval_2El__891;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();

static long ___L__1668__eval_2El__891[] = {

static long ___L__1674__eval_2El__892[] = {
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp1 = _acc;

static long ___L__1675__eval_2El__893[] = {
  goto ___L__1677__eval_2El__893;

static long ___L__1676__eval_2El__893[] = {

static long ___L__1678__eval_2El__894[] = {
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp6 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__1679__eval_2El__895[] = {
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp1 = _acc;

static long ___L__1677__eval_2El__893[] = {

static long ___L__1680__eval_2El__893[] = {
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = LONG(0);
  _acc = _tmp6;
  if (_acc == nil) goto ___L__1681__eval_2El__893;
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = _tmp6;
  _acc = LONG(getLong(_acc) & getLong(_tmp5));
  if (_acc == nil) goto ___L__1683__eval_2El__893;
  _acc = __3Clong_3E;
  goto ___L__1684__eval_2El__893;

static long ___L__1683__eval_2El__893[] = {
  _acc = LONG(-1);
  _tmp5 = _acc;
  _acc = _tmp6;
  _acc = ((oop*)_acc)[getLong(_tmp5)];

static long ___L__1684__eval_2El__893[] = {
  goto ___L__1682__eval_2El__893;

static long ___L__1681__eval_2El__893[] = {
  _acc = __3Cundefined_3E;

static long ___L__1682__eval_2El__893[] = {
  _tmp6 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp6) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1676__eval_2El__893;

static long ___L__1685__eval_2El__896[] = {
  _acc = _tmp2;
  _tmp6 = _acc;
  _acc = LONG(0);
  _acc = LONG(4);
  _tmp5 = _acc;
  _acc = __3Cenv_3E;
  _tmp3 = _acc;
  _acc = _tmp6;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  if (_acc == nil) goto ___L__1686__eval_2El__896;
  _acc = _tmp2;
  _tmp6 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = LONG(3);
  _tmp8 = _acc;
  _acc = __3Ccontext_3E;
  _tmp3 = _acc;
  _acc = _tmp6;
  _tmp9 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp9;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp8)] = _tmp5;

static long ___L__1686__eval_2El__896[] = {
  _acc = _tmp0;
  _tmp6 = _acc;

static long ___L__1687__eval_2El__881[] = {
  _acc = (oop)&_tmp2;
  _tmp5 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = (oop)&_tmp1;
  _tmp5 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp6;
return _acc;
}

oop k_apply_expr = (oop)k_apply_expr;
## defn k_eval
oop k_eval(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1688__eval_2El__1053[] = {
  _acc = _opt__verbose;
  _tmp0 = _acc;
  _acc = LONG(2);
  _acc = (getLong(_acc) < getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1689__eval_2El__1053;

static long ___L__1690__eval_2El__1053[] = {
  "  E  "
,
    _acc = (oop)___L__1690__eval_2El__1053;
  _tmp0 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__dump;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1691__eval_2El__1053[] = {
  " "
,
    _acc = (oop)___L__1691__eval_2El__1053;
  _tmp0 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _k__dumpln;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _stdout;
  _tmp0 = _acc;
  _acc = _fflush_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1689__eval_2El__1053[] = {

static long ___L__1692__eval_2El__1054[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__1693__eval_2El__1054;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__1695__eval_2El__1054;
  _acc = __3Clong_3E;
  goto ___L__1696__eval_2El__1054;

static long ___L__1695__eval_2El__1054[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__1696__eval_2El__1054[] = {
  goto ___L__1694__eval_2El__1054;

static long ___L__1693__eval_2El__1054[] = {
  _acc = __3Cundefined_3E;

static long ___L__1694__eval_2El__1054[] = {
  _tmp0 = _acc;

static long ___L__1697__eval_2El__1055[] = {

static long ___L__1700__eval_2El__1056[] = {
  _acc = __3Cundefined_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1698__eval_2El__1055;
  _acc = _tmp0;
  goto ___L__1699__eval_2El__1055;

static long ___L__1698__eval_2El__1055[] = {

static long ___L__1701__eval_2El__1055[] = {

static long ___L__1704__eval_2El__1057[] = {
  _acc = __3Clong_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1702__eval_2El__1055;
  _acc = _tmp0;
  goto ___L__1703__eval_2El__1055;

static long ___L__1702__eval_2El__1055[] = {

static long ___L__1705__eval_2El__1055[] = {

static long ___L__1708__eval_2El__1058[] = {
  _acc = __3Cstring_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1706__eval_2El__1055;
  _acc = _tmp0;
  goto ___L__1707__eval_2El__1055;

static long ___L__1706__eval_2El__1055[] = {

static long ___L__1709__eval_2El__1055[] = {

static long ___L__1712__eval_2El__1059[] = {
  _acc = __3Cvariable_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1710__eval_2El__1055;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _is__global;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__1713__eval_2El__1059;

static long ___L__1715__eval_2El__1060[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  goto ___L__1714__eval_2El__1059;

static long ___L__1713__eval_2El__1059[] = {

static long ___L__1716__eval_2El__1061[] = {

static long ___L__1717__eval_2El__1062[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cenv_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp1 = _acc;

static long ___L__1718__eval_2El__1061[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = __3Ccontext_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = __3Cenv_3E;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _acc = LONG(getLong(_acc) - getLong(_tmp1));
  _tmp1 = _acc;

static long ___L__1719__eval_2El__1063[] = {
  goto ___L__1721__eval_2El__1063;

static long ___L__1720__eval_2El__1063[] = {

static long ___L__1722__eval_2El__1064[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Ccontext_3E;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp1 = _acc;

static long ___L__1723__eval_2El__1065[] = {
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) - getLong(_tmp2));
  _tmp1 = _acc;

static long ___L__1721__eval_2El__1063[] = {

static long ___L__1724__eval_2El__1063[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = (getLong(_acc) < getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1720__eval_2El__1063;

static long ___L__1725__eval_2El__1066[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp3 = _acc;
  _acc = __3Ccontext_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(3);
  _tmp5 = _acc;
  _acc = __3Cvariable_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Clong_3E;
  _tmp6 = _acc;
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp3 = _acc;
  _acc = _k__array__at;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1714__eval_2El__1059[] = {
  goto ___L__1711__eval_2El__1055;

static long ___L__1710__eval_2El__1055[] = {

static long ___L__1726__eval_2El__1055[] = {

static long ___L__1729__eval_2El__1067[] = {
  _acc = __3Cpair_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1727__eval_2El__1055;
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _k__eval;
  _tmp0 = _tmp1;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp3 = _acc;

static long ___L__1730__eval_2El__1068[] = {
  _acc = (oop)&_tmp3;
  _tmp1 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1731__eval_2El__1069[] = {
  _acc = _trace__stack;
  _tmp1 = _acc;
  _acc = _trace__depth;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _k__set__array__at;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__1732__eval_2El__1070[] = {
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = _trace__depth;
  _acc = LONG(getLong(_acc) + getLong(_tmp5));
  _trace__depth = _acc;

static long ___L__1733__eval_2El__1071[] = {
  _acc = _tmp3;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = _tmp5;
  if (_acc == nil) goto ___L__1736__eval_2El__1071;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp5;
  _acc = LONG(getLong(_acc) & getLong(_tmp2));
  if (_acc == nil) goto ___L__1738__eval_2El__1071;
  _acc = __3Clong_3E;
  goto ___L__1739__eval_2El__1071;

static long ___L__1738__eval_2El__1071[] = {
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp5;
  _acc = ((oop*)_acc)[getLong(_tmp2)];

static long ___L__1739__eval_2El__1071[] = {
  goto ___L__1737__eval_2El__1071;

static long ___L__1736__eval_2El__1071[] = {
  _acc = __3Cundefined_3E;

static long ___L__1737__eval_2El__1071[] = {
  _tmp5 = _acc;
  _acc = __3Cfixed_3E;
  _acc = (_acc == _tmp5) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1734__eval_2El__1071;

static long ___L__1740__eval_2El__1072[] = {
  _acc = _tmp3;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cfixed_3E;
  _tmp1 = _acc;
  _acc = _tmp5;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp5 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _k__apply;
  _tmp0 = _tmp5;
  _tmp1 = _tmp2;
  _tmp2 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  goto ___L__1735__eval_2El__1071;

static long ___L__1734__eval_2El__1071[] = {

static long ___L__1741__eval_2El__1073[] = {
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _evlist;
  _tmp0 = _tmp4;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1742__eval_2El__1074[] = {
  _acc = (oop)&_tmp2;
  _tmp4 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1743__eval_2El__1075[] = {
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _k__apply;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _tmp2 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp1 = _acc;

static long ___L__1744__eval_2El__1074[] = {
  _acc = (oop)&_tmp2;
  _tmp5 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;

static long ___L__1735__eval_2El__1071[] = {
  _tmp3 = _acc;

static long ___L__1745__eval_2El__1076[] = {
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _trace__depth;
  _acc = LONG(getLong(_acc) - getLong(_tmp2));
  _trace__depth = _acc;
  _acc = _tmp3;
  _tmp2 = _acc;

static long ___L__1746__eval_2El__1068[] = {
  _acc = (oop)&_tmp3;
  _tmp1 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp2;
  goto ___L__1728__eval_2El__1055;

static long ___L__1727__eval_2El__1055[] = {

static long ___L__1747__eval_2El__1055[] = {

static long ___L__1750__eval_2El__1078[] = {
  _acc = __3Csymbol_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1748__eval_2El__1055;

static long ___L__1751__eval_2El__1078[] = {
  "\012eval.k: error: "
,
    _acc = (oop)___L__1751__eval_2El__1078;
  _tmp3 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1752__eval_2El__1078[] = {
  "symbol in eval?"
,
    _acc = (oop)___L__1752__eval_2El__1078;
  _tmp3 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1753__eval_2El__1078[] = {
  "\012"
,
    _acc = (oop)___L__1753__eval_2El__1078;
  _tmp3 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();
  goto ___L__1749__eval_2El__1055;

static long ___L__1748__eval_2El__1055[] = {

static long ___L__1754__eval_2El__1079[] = {
  _acc = _evaluators;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp1 = _acc;
  _acc = _tmp3;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1755__eval_2El__1079;
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp5));
  if (_acc == nil) goto ___L__1757__eval_2El__1079;
  _acc = __3Clong_3E;
  goto ___L__1758__eval_2El__1079;

static long ___L__1757__eval_2El__1079[] = {
  _acc = LONG(-1);
  _tmp5 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp5)];

static long ___L__1758__eval_2El__1079[] = {
  goto ___L__1756__eval_2El__1079;

static long ___L__1755__eval_2El__1079[] = {
  _acc = __3Cundefined_3E;

static long ___L__1756__eval_2El__1079[] = {
  _tmp2 = _acc;
  _acc = _k__array__at;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1759__eval_2El__1080[] = {
  _acc = _tmp2;
  if (_acc == nil) goto ___L__1760__eval_2El__1080;

static long ___L__1761__eval_2El__1081[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp3;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp5 = _acc;

static long ___L__1762__eval_2El__1082[] = {
  _acc = (oop)&_tmp5;
  _tmp3 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1763__eval_2El__1083[] = {
  _acc = _trace__stack;
  _tmp3 = _acc;
  _acc = _trace__depth;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = _k__set__array__at;
  _tmp0 = _tmp3;
  _tmp1 = _tmp1;
  _tmp2 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__1764__eval_2El__1084[] = {
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _trace__depth;
  _acc = LONG(getLong(_acc) + getLong(_tmp4));
  _trace__depth = _acc;

static long ___L__1765__eval_2El__1085[] = {
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = _tmp5;
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _k__apply;
  _tmp0 = _tmp4;
  _tmp1 = _tmp1;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp0 = _acc;

static long ___L__1766__eval_2El__1086[] = {
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _trace__depth;
  _acc = LONG(getLong(_acc) - getLong(_tmp3));
  _trace__depth = _acc;
  _tmp3 = _acc;

static long ___L__1767__eval_2El__1082[] = {
  _acc = (oop)&_tmp5;
  _tmp1 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp3;

static long ___L__1760__eval_2El__1080[] = {
  _acc = _tmp0;

static long ___L__1749__eval_2El__1055[] = {

static long ___L__1728__eval_2El__1055[] = {

static long ___L__1711__eval_2El__1055[] = {

static long ___L__1707__eval_2El__1055[] = {

static long ___L__1703__eval_2El__1055[] = {

static long ___L__1699__eval_2El__1055[] = {
return _acc;
}

oop k_eval = (oop)k_eval;
## defn k_env_define
oop k_env_define(oop _param0, oop _param1, oop _param2) {
  oop _acc = nil;

static long ___L__1768__eval_2El__855[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(3);
  _tmp1 = _acc;
  _acc = __3Cenv_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp0 = _acc;

static long ___L__1769__eval_2El__856[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__array__length;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__1770__eval_2El__857[] = {
  goto ___L__1772__eval_2El__857;

static long ___L__1771__eval_2El__857[] = {

static long ___L__1773__eval_2El__858[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__array__at;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1774__eval_2El__859[] = {
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = __3Cvariable_3E;
  _tmp5 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1775__eval_2El__859;

static long ___L__1776__eval_2El__860[] = {

static long ___L__1777__eval_2El__861[] = {
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = __3Cvariable_3E;
  _tmp5 = _acc;
  _acc = _tmp3;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp6)] = _tmp4;

static long ___L__1778__eval_2El__862[] = {
  _acc = _tmp2;
  goto ___L__1779__eval_2El__862;

static long ___L__1775__eval_2El__859[] = {

static long ___L__1772__eval_2El__857[] = {

static long ___L__1780__eval_2El__857[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) - getLong(_tmp3));
  _tmp1 = _acc;
  _acc = (getLong(_acc) >= getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1771__eval_2El__857;

static long ___L__1781__eval_2El__863[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp3 = _acc;
  _acc = __3Cenv_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp6 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;

static long ___L__1782__eval_2El__864[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp6 = _acc;
  _acc = _tmp2;
  _tmp7 = _acc;
  _acc = _new_2D_3Cvariable_3E;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _tmp2 = _tmp6;
  _tmp3 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2, _arg3);
  _tmp7 = _acc;

static long ___L__1783__eval_2El__865[] = {
  _acc = (oop)&_tmp7;
  _tmp6 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1784__eval_2El__866[] = {
  _acc = _tmp0;
  _tmp6 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) + getLong(_tmp4));
  _tmp4 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp4 = _acc;
  _acc = LONG(2);
  _tmp3 = _acc;
  _acc = __3Cenv_3E;
  _tmp5 = _acc;
  _acc = _tmp6;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp3)] = _tmp4;

static long ___L__1785__eval_2El__867[] = {
  _acc = _tmp0;
  _tmp6 = _acc;
  _acc = _tmp7;
  _tmp4 = _acc;
  _acc = _k__array__append;
  _tmp0 = _tmp6;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp4 = _acc;

static long ___L__1786__eval_2El__865[] = {
  _acc = (oop)&_tmp7;
  _tmp6 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp4;
___L__1779__eval_2El__862:
  return _acc;
}

oop k_env_define = (oop)k_env_define;
## defn k_env_lookup
oop k_env_lookup(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1787__eval_2El__849[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _k__env__find__variable;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__1788__eval_2El__850[] = {
  _acc = _tmp1;
  if (_acc == nil) goto ___L__1789__eval_2El__850;

static long ___L__1791__eval_2El__851[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  goto ___L__1790__eval_2El__850;

static long ___L__1789__eval_2El__850[] = {

static long ___L__1792__eval_2El__852[] = {

static long ___L__1793__eval_2El__852[] = {
  "undefined variable: %s"
,
    _acc = (oop)___L__1793__eval_2El__852;
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = __3Csymbol_3E;
  _tmp3 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp2 = _acc;
  _acc = _fatal1;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1790__eval_2El__850[] = {
return _acc;
}

oop k_env_lookup = (oop)k_env_lookup;
## defn k_env_find_variable
oop k_env_find_variable(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1794__eval_2El__838[] = {
  goto ___L__1796__eval_2El__838;

static long ___L__1795__eval_2El__838[] = {

static long ___L__1797__eval_2El__839[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(3);
  _tmp1 = _acc;
  _acc = __3Cenv_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp0 = _acc;

static long ___L__1798__eval_2El__840[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__array__length;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__1799__eval_2El__839[] = {

static long ___L__1800__eval_2El__841[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Carray_3E;
  _tmp4 = _acc;
  _acc = _tmp3;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp3 = _acc;

static long ___L__1801__eval_2El__842[] = {
  goto ___L__1803__eval_2El__842;

static long ___L__1802__eval_2El__842[] = {

static long ___L__1804__eval_2El__843[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _tmp3;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;

static long ___L__1805__eval_2El__844[] = {
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = __3Cvariable_3E;
  _tmp6 = _acc;
  _acc = _tmp5;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp5 = _acc;
  _acc = _tmp1;
  _acc = (_acc == _tmp5) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1806__eval_2El__844;

static long ___L__1807__eval_2El__845[] = {
  _acc = _tmp2;
  goto ___L__1808__eval_2El__845;

static long ___L__1806__eval_2El__844[] = {

static long ___L__1803__eval_2El__842[] = {

static long ___L__1809__eval_2El__842[] = {
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) - getLong(_tmp2));
  _tmp1 = _acc;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = (getLong(_acc) <= getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1802__eval_2El__842;

static long ___L__1810__eval_2El__846[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Cenv_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp0 = _acc;

static long ___L__1796__eval_2El__838[] = {
  _acc = _tmp0;
  if (_acc != nil) goto ___L__1795__eval_2El__838;
___L__1808__eval_2El__845:
  return _acc;
}

oop k_env_find_variable = (oop)k_env_find_variable;
## defn read_quote
oop read_quote(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1811__eval_2El__800[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _k__read;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__1812__eval_2El__801[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _DONE;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1813__eval_2El__801;

static long ___L__1814__eval_2El__801[] = {
  "EOF while reading quoted literal"
,
    _acc = (oop)___L__1814__eval_2El__801;
  _tmp1 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1813__eval_2El__801[] = {

static long ___L__1815__eval_2El__802[] = {
  _acc = (oop)&_tmp0;
  _tmp1 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1816__eval_2El__803[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__1817__eval_2El__804[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;

static long ___L__1818__eval_2El__802[] = {
  _acc = (oop)&_tmp0;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp1;
return _acc;
}

oop read_quote = (oop)read_quote;
## defn read_list
oop read_list(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1819__eval_2El__786[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;

static long ___L__1820__eval_2El__789[] = {
  _acc = (oop)&_tmp1;
  _tmp3 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = (oop)&_tmp2;
  _tmp3 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1821__eval_2El__790[] = {
  goto ___L__1823__eval_2El__790;

static long ___L__1822__eval_2El__790[] = {

static long ___L__1824__eval_2El__791[] = {
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__1825__eval_2El__792[] = {
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp0;
  ((oop*)_acc)[getLong(_tmp3)] = _tmp4;
  _tmp0 = _acc;

static long ___L__1823__eval_2El__790[] = {

static long ___L__1826__eval_2El__790[] = {
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _k__read;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _tmp4 = _acc;
  _acc = _DONE;
  _acc = (_acc != _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1827__eval_2El__790;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = _s__dot;
  _acc = (_acc != _tmp4) ? LONG(1) : LONG(0);

static long ___L__1827__eval_2El__790[] = {
  if (_acc != nil) goto ___L__1822__eval_2El__790;

static long ___L__1828__eval_2El__793[] = {
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = _s__dot;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1829__eval_2El__793;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _k__read;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp4 = _acc;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp0;
  ((oop*)_acc)[getLong(_tmp3)] = _tmp4;

static long ___L__1829__eval_2El__793[] = {
  _tmp4 = _acc;

static long ___L__1830__eval_2El__789[] = {
  _acc = (oop)&_tmp2;
  _tmp3 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = (oop)&_tmp1;
  _tmp3 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp4;

static long ___L__1831__eval_2El__794[] = {
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp4 = _acc;

static long ___L__1832__eval_2El__795[] = {
  _acc = _tmp4;
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1833__eval_2El__795;

static long ___L__1835__eval_2El__796[] = {
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  goto ___L__1834__eval_2El__795;

static long ___L__1833__eval_2El__795[] = {

static long ___L__1836__eval_2El__797[] = {

static long ___L__1837__eval_2El__797[] = {
  "missing closing '%c' delimiter while reading list"
,
    _acc = (oop)___L__1837__eval_2El__797;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _fatal1;
  _tmp0 = _tmp3;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1834__eval_2El__795[] = {
return _acc;
}

oop read_list = (oop)read_list;
## defn k_read
oop k_read(oop _param0) {
  oop _acc = nil;

static long ___L__1838__eval_2El__808[] = {
  goto ___L__1840__eval_2El__808;

static long ___L__1839__eval_2El__808[] = {

static long ___L__1841__eval_2El__809[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__1842__eval_2El__810[] = {

static long ___L__1845__eval_2El__811[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _is__blank;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__1843__eval_2El__810;
  _acc = LONG(0);
  goto ___L__1844__eval_2El__810;

static long ___L__1843__eval_2El__810[] = {

static long ___L__1846__eval_2El__810[] = {

static long ___L__1849__eval_2El__812[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(63);
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1847__eval_2El__810;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _read__char;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__1850__eval_2El__812;
  goto ___L__1848__eval_2El__810;

static long ___L__1847__eval_2El__810[] = {

static long ___L__1851__eval_2El__810[] = {

static long ___L__1854__eval_2El__813[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(45);
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1852__eval_2El__810;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _ungetc_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;
  _acc = _is__digit10;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__1855__eval_2El__813;

static long ___L__1857__eval_2El__814[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _read__number;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__1856__eval_2El__813;

static long ___L__1855__eval_2El__813[] = {

static long ___L__1858__eval_2El__815[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _read__symbol;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1856__eval_2El__813[] = {
  goto ___L__1850__eval_2El__812;
  goto ___L__1853__eval_2El__810;

static long ___L__1852__eval_2El__810[] = {

static long ___L__1859__eval_2El__810[] = {

static long ___L__1862__eval_2El__816[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(39);
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1860__eval_2El__810;
  _acc = _s__quote;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _read__quote;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__1850__eval_2El__812;
  goto ___L__1861__eval_2El__810;

static long ___L__1860__eval_2El__810[] = {

static long ___L__1863__eval_2El__810[] = {

static long ___L__1866__eval_2El__817[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(96);
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1864__eval_2El__810;
  _acc = _s__quasiquote;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _read__quote;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__1850__eval_2El__812;
  goto ___L__1865__eval_2El__810;

static long ___L__1864__eval_2El__810[] = {

static long ___L__1867__eval_2El__810[] = {

static long ___L__1870__eval_2El__818[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(44);
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1868__eval_2El__810;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__1871__eval_2El__819[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = LONG(64);
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1872__eval_2El__819;

static long ___L__1874__eval_2El__820[] = {
  _acc = _s__unquote__splicing;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _read__quote;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__1873__eval_2El__819;

static long ___L__1872__eval_2El__819[] = {

static long ___L__1875__eval_2El__821[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _ungetc_24stub;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1876__eval_2El__822[] = {
  _acc = _s__unquote;
  _tmp2 = _acc;
  _acc = _read__quote;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1873__eval_2El__819[] = {
  goto ___L__1850__eval_2El__812;
  goto ___L__1869__eval_2El__810;

static long ___L__1868__eval_2El__810[] = {

static long ___L__1877__eval_2El__810[] = {

static long ___L__1880__eval_2El__823[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _is__letter;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__1878__eval_2El__810;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _read__symbol;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__1850__eval_2El__812;
  goto ___L__1879__eval_2El__810;

static long ___L__1878__eval_2El__810[] = {

static long ___L__1881__eval_2El__810[] = {

static long ___L__1884__eval_2El__824[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(40);
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1882__eval_2El__810;
  _acc = LONG(41);
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _read__list;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__1850__eval_2El__812;
  goto ___L__1883__eval_2El__810;

static long ___L__1882__eval_2El__810[] = {

static long ___L__1885__eval_2El__810[] = {

static long ___L__1888__eval_2El__824[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(41);
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1886__eval_2El__810;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _ungetc_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = _DONE;
  goto ___L__1850__eval_2El__812;
  goto ___L__1887__eval_2El__810;

static long ___L__1886__eval_2El__810[] = {

static long ___L__1889__eval_2El__810[] = {

static long ___L__1892__eval_2El__825[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(91);
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1890__eval_2El__810;
  _acc = LONG(93);
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _read__list;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__1850__eval_2El__812;
  goto ___L__1891__eval_2El__810;

static long ___L__1890__eval_2El__810[] = {

static long ___L__1893__eval_2El__810[] = {

static long ___L__1896__eval_2El__825[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(93);
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1894__eval_2El__810;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _ungetc_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = _DONE;
  goto ___L__1850__eval_2El__812;
  goto ___L__1895__eval_2El__810;

static long ___L__1894__eval_2El__810[] = {

static long ___L__1897__eval_2El__810[] = {

static long ___L__1900__eval_2El__826[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(123);
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1898__eval_2El__810;
  _acc = LONG(125);
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _read__list;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__1850__eval_2El__812;
  goto ___L__1899__eval_2El__810;

static long ___L__1898__eval_2El__810[] = {

static long ___L__1901__eval_2El__810[] = {

static long ___L__1904__eval_2El__826[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(125);
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1902__eval_2El__810;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _ungetc_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = _DONE;
  goto ___L__1850__eval_2El__812;
  goto ___L__1903__eval_2El__810;

static long ___L__1902__eval_2El__810[] = {

static long ___L__1905__eval_2El__810[] = {

static long ___L__1908__eval_2El__827[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _is__digit10;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__1906__eval_2El__810;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _read__number;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__1850__eval_2El__812;
  goto ___L__1907__eval_2El__810;

static long ___L__1906__eval_2El__810[] = {

static long ___L__1909__eval_2El__810[] = {

static long ___L__1912__eval_2El__828[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(59);
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1910__eval_2El__810;
  goto ___L__1914__eval_2El__828;

static long ___L__1913__eval_2El__828[] = {

static long ___L__1914__eval_2El__828[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _tmp1 = _acc;
  _acc = LONG(10);
  _acc = (_acc != _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1915__eval_2El__828;

static long ___L__1916__eval_2El__829[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(13);
  _acc = (_acc != _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1915__eval_2El__828;

static long ___L__1917__eval_2El__830[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _EOF;
  _acc = (_acc != _tmp1) ? LONG(1) : LONG(0);

static long ___L__1915__eval_2El__828[] = {
  if (_acc != nil) goto ___L__1913__eval_2El__828;
  goto ___L__1911__eval_2El__810;

static long ___L__1910__eval_2El__810[] = {

static long ___L__1918__eval_2El__810[] = {

static long ___L__1921__eval_2El__831[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(34);
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1919__eval_2El__810;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _read__string;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__1850__eval_2El__812;
  goto ___L__1920__eval_2El__810;

static long ___L__1919__eval_2El__810[] = {

static long ___L__1922__eval_2El__810[] = {

static long ___L__1925__eval_2El__832[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) < getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1923__eval_2El__810;
  _acc = _DONE;
  goto ___L__1850__eval_2El__812;
  goto ___L__1924__eval_2El__810;

static long ___L__1923__eval_2El__810[] = {

static long ___L__1926__eval_2El__833[] = {

static long ___L__1927__eval_2El__833[] = {
  "illegal character: %c"
,
    _acc = (oop)___L__1927__eval_2El__833;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _fatal1;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1924__eval_2El__810[] = {

static long ___L__1920__eval_2El__810[] = {

static long ___L__1911__eval_2El__810[] = {

static long ___L__1907__eval_2El__810[] = {

static long ___L__1903__eval_2El__810[] = {

static long ___L__1899__eval_2El__810[] = {

static long ___L__1895__eval_2El__810[] = {

static long ___L__1891__eval_2El__810[] = {

static long ___L__1887__eval_2El__810[] = {

static long ___L__1883__eval_2El__810[] = {

static long ___L__1879__eval_2El__810[] = {

static long ___L__1869__eval_2El__810[] = {

static long ___L__1865__eval_2El__810[] = {

static long ___L__1861__eval_2El__810[] = {

static long ___L__1853__eval_2El__810[] = {

static long ___L__1848__eval_2El__810[] = {

static long ___L__1844__eval_2El__810[] = {

static long ___L__1840__eval_2El__808[] = {
  _acc = LONG(1);
  if (_acc != nil) goto ___L__1839__eval_2El__808;
___L__1850__eval_2El__812:
  return _acc;
}

oop k_read = (oop)k_read;
## defn read_string
oop read_string(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1928__eval_2El__773[] = {
  _acc = _new__buffer;
  _acc = ((oop (*)())_acc)();
  _tmp0 = _acc;

static long ___L__1929__eval_2El__774[] = {
  goto ___L__1931__eval_2El__774;

static long ___L__1930__eval_2El__774[] = {

static long ___L__1932__eval_2El__775[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _read__char;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__1933__eval_2El__776[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _EOF;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1934__eval_2El__776;

static long ___L__1935__eval_2El__776[] = {
  "unterminated string literal"
,
    _acc = (oop)___L__1935__eval_2El__776;
  _tmp2 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1934__eval_2El__776[] = {

static long ___L__1936__eval_2El__777[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _buffer__append;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1931__eval_2El__774[] = {

static long ___L__1937__eval_2El__774[] = {
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _tmp1 = _acc;
  _acc = LONG(34);
  _acc = (_acc != _tmp1) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__1930__eval_2El__774;

static long ___L__1938__eval_2El__778[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _buffer__append;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1939__eval_2El__779[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;
  _acc = _new_2D_3Cstring_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;

static long ___L__1940__eval_2El__780[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _buffer__delete;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp2;
return _acc;
}

oop read_string = (oop)read_string;
## defn read_symbol
oop read_symbol(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1941__eval_2El__762[] = {
  _acc = _new__buffer;
  _acc = ((oop (*)())_acc)();
  _tmp0 = _acc;

static long ___L__1942__eval_2El__763[] = {
  goto ___L__1944__eval_2El__763;

static long ___L__1943__eval_2El__763[] = {

static long ___L__1945__eval_2El__764[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _buffer__append;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1946__eval_2El__765[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__1944__eval_2El__763[] = {

static long ___L__1947__eval_2El__763[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _is__letter;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc != nil) goto ___L__1948__eval_2El__763;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _is__digit10;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1948__eval_2El__763[] = {
  if (_acc != nil) goto ___L__1943__eval_2El__763;

static long ___L__1949__eval_2El__766[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _ungetc_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1950__eval_2El__767[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _buffer__append;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1951__eval_2El__768[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;
  _acc = _intern;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;

static long ___L__1952__eval_2El__769[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _buffer__delete;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp2;
return _acc;
}

oop read_symbol = (oop)read_symbol;
## defn read_number
oop read_number(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1953__eval_2El__747[] = {
  _acc = _new__buffer;
  _acc = ((oop (*)())_acc)();
  _tmp0 = _acc;

static long ___L__1954__eval_2El__748[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(45);
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  _tmp1 = _acc;

static long ___L__1955__eval_2El__749[] = {
  _acc = _tmp1;
  if (_acc != nil) goto ___L__1956__eval_2El__749;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _buffer__append;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1956__eval_2El__749[] = {

static long ___L__1957__eval_2El__750[] = {
  goto ___L__1959__eval_2El__750;

static long ___L__1958__eval_2El__750[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _buffer__append;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1959__eval_2El__750[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _tmp2 = _acc;
  _acc = _is__digit10;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc != nil) goto ___L__1958__eval_2El__750;

static long ___L__1960__eval_2El__751[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(120);
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1961__eval_2El__751;
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;
  _acc = LONG(1);
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1961__eval_2El__751;

static long ___L__1962__eval_2El__752[] = {

static long ___L__1963__eval_2El__753[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = _buffer__append;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1964__eval_2El__754[] = {
  goto ___L__1966__eval_2El__754;

static long ___L__1965__eval_2El__754[] = {
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _buffer__append;
  _tmp0 = _tmp4;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1966__eval_2El__754[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _tmp2 = _acc;
  _acc = _is__digit16;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc != nil) goto ___L__1965__eval_2El__754;

static long ___L__1961__eval_2El__751[] = {

static long ___L__1967__eval_2El__755[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _ungetc_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1968__eval_2El__756[] = {
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _buffer__append;
  _tmp0 = _tmp4;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__1969__eval_2El__757[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = _strtoul_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _tmp2 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp4 = _acc;

static long ___L__1970__eval_2El__758[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _buffer__delete;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__1971__eval_2El__759[] = {
  _acc = _tmp1;
  if (_acc == nil) goto ___L__1972__eval_2El__759;
  _acc = _tmp4;
  _acc = LONG(-getLong(_acc));
  goto ___L__1973__eval_2El__759;

static long ___L__1972__eval_2El__759[] = {
  _acc = _tmp4;

static long ___L__1973__eval_2El__759[] = {
  _tmp3 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop read_number = (oop)read_number;
## defn read_char
oop read_char(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__1974__eval_2El__702[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(92);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1975__eval_2El__702;

static long ___L__1977__eval_2El__703[] = {

static long ___L__1978__eval_2El__704[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__1979__eval_2El__705[] = {

static long ___L__1982__eval_2El__706[] = {
  _acc = LONG(97);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1980__eval_2El__705;
  _acc = LONG(7);
  goto ___L__1981__eval_2El__705;

static long ___L__1980__eval_2El__705[] = {

static long ___L__1983__eval_2El__705[] = {

static long ___L__1986__eval_2El__707[] = {
  _acc = LONG(98);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1984__eval_2El__705;
  _acc = LONG(8);
  goto ___L__1985__eval_2El__705;

static long ___L__1984__eval_2El__705[] = {

static long ___L__1987__eval_2El__705[] = {

static long ___L__1990__eval_2El__708[] = {
  _acc = LONG(102);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1988__eval_2El__705;
  _acc = LONG(12);
  goto ___L__1989__eval_2El__705;

static long ___L__1988__eval_2El__705[] = {

static long ___L__1991__eval_2El__705[] = {

static long ___L__1994__eval_2El__709[] = {
  _acc = LONG(110);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1992__eval_2El__705;
  _acc = LONG(10);
  goto ___L__1993__eval_2El__705;

static long ___L__1992__eval_2El__705[] = {

static long ___L__1995__eval_2El__705[] = {

static long ___L__1998__eval_2El__710[] = {
  _acc = LONG(114);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__1996__eval_2El__705;
  _acc = LONG(13);
  goto ___L__1997__eval_2El__705;

static long ___L__1996__eval_2El__705[] = {

static long ___L__1999__eval_2El__705[] = {

static long ___L__2002__eval_2El__711[] = {
  _acc = LONG(116);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2000__eval_2El__705;
  _acc = LONG(9);
  goto ___L__2001__eval_2El__705;

static long ___L__2000__eval_2El__705[] = {

static long ___L__2003__eval_2El__705[] = {

static long ___L__2006__eval_2El__712[] = {
  _acc = LONG(118);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2004__eval_2El__705;
  _acc = LONG(11);
  goto ___L__2005__eval_2El__705;

static long ___L__2004__eval_2El__705[] = {

static long ___L__2007__eval_2El__705[] = {

static long ___L__2010__eval_2El__713[] = {
  _acc = LONG(117);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2008__eval_2El__705;
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__2011__eval_2El__714[] = {
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__2012__eval_2El__715[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;

static long ___L__2013__eval_2El__716[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp3 = _acc;

static long ___L__2014__eval_2El__717[] = {

static long ___L__2015__eval_2El__718[] = {

static long ___L__2016__eval_2El__719[] = {

static long ___L__2017__eval_2El__720[] = {
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = _digit__value;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp4 = _acc;

static long ___L__2018__eval_2El__719[] = {
  _acc = LONG(8);
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp6 = _acc;
  _acc = _digit__value;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = LONG(getLong(_acc) << getLong(_tmp5));
  _acc = LONG(getLong(_acc) + getLong(_tmp4));
  _tmp4 = _acc;

static long ___L__2019__eval_2El__718[] = {
  _acc = LONG(16);
  _tmp5 = _acc;
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = _digit__value;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = LONG(getLong(_acc) << getLong(_tmp5));
  _acc = LONG(getLong(_acc) + getLong(_tmp4));
  _tmp4 = _acc;

static long ___L__2020__eval_2El__717[] = {
  _acc = LONG(24);
  _tmp5 = _acc;
  _acc = _tmp0;
  _tmp6 = _acc;
  _acc = _digit__value;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = LONG(getLong(_acc) << getLong(_tmp5));
  _acc = LONG(getLong(_acc) + getLong(_tmp4));
  goto ___L__2009__eval_2El__705;

static long ___L__2008__eval_2El__705[] = {

static long ___L__2021__eval_2El__705[] = {

static long ___L__2024__eval_2El__721[] = {
  _acc = LONG(120);
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2022__eval_2El__705;
  _acc = LONG(0);
  _tmp3 = _acc;

static long ___L__2025__eval_2El__722[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _tmp2 = _acc;
  _acc = _is__hexadecimal;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__2026__eval_2El__722;

static long ___L__2028__eval_2El__723[] = {

static long ___L__2029__eval_2El__724[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _digit__value;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp3 = _acc;

static long ___L__2030__eval_2El__725[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _tmp2 = _acc;
  _acc = _is__hexadecimal;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__2031__eval_2El__725;

static long ___L__2033__eval_2El__726[] = {

static long ___L__2034__eval_2El__727[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _digit__value;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _acc = LONG(16);
  _tmp1 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) * getLong(_tmp1));
  _acc = LONG(getLong(_acc) + getLong(_tmp2));
  _tmp3 = _acc;

static long ___L__2035__eval_2El__728[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  goto ___L__2032__eval_2El__725;

static long ___L__2031__eval_2El__725[] = {

static long ___L__2032__eval_2El__725[] = {
  goto ___L__2027__eval_2El__722;

static long ___L__2026__eval_2El__722[] = {

static long ___L__2027__eval_2El__722[] = {

static long ___L__2036__eval_2El__729[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _ungetc_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = _tmp3;
  goto ___L__2023__eval_2El__705;

static long ___L__2022__eval_2El__705[] = {

static long ___L__2037__eval_2El__705[] = {

static long ___L__2040__eval_2El__731[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(48);
  _acc = (getLong(_acc) <= getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2041__eval_2El__731;
  _acc = LONG(55);
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp3)) ? LONG(1) : LONG(0);

static long ___L__2041__eval_2El__731[] = {
  if (_acc == nil) goto ___L__2038__eval_2El__705;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _digit__value;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp3 = _acc;

static long ___L__2042__eval_2El__732[] = {
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _tmp1 = _acc;
  _acc = _is__octal;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__2043__eval_2El__732;

static long ___L__2045__eval_2El__733[] = {

static long ___L__2046__eval_2El__734[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _digit__value;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = LONG(8);
  _tmp2 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) * getLong(_tmp2));
  _acc = LONG(getLong(_acc) + getLong(_tmp1));
  _tmp3 = _acc;

static long ___L__2047__eval_2El__735[] = {
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _tmp1 = _acc;
  _acc = _is__octal;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc == nil) goto ___L__2048__eval_2El__735;

static long ___L__2050__eval_2El__736[] = {

static long ___L__2051__eval_2El__737[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _digit__value;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = LONG(8);
  _tmp2 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) * getLong(_tmp2));
  _acc = LONG(getLong(_acc) + getLong(_tmp1));
  _tmp3 = _acc;

static long ___L__2052__eval_2El__738[] = {
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _getc_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  goto ___L__2049__eval_2El__735;

static long ___L__2048__eval_2El__735[] = {

static long ___L__2049__eval_2El__735[] = {
  goto ___L__2044__eval_2El__732;

static long ___L__2043__eval_2El__732[] = {

static long ___L__2044__eval_2El__732[] = {

static long ___L__2053__eval_2El__739[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _ungetc_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = _tmp3;
  goto ___L__2039__eval_2El__705;

static long ___L__2038__eval_2El__705[] = {

static long ___L__2054__eval_2El__741[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _is__alpha;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  if (_acc != nil) goto ___L__2057__eval_2El__741;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _is__digit10;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2057__eval_2El__741[] = {
  if (_acc == nil) goto ___L__2055__eval_2El__741;

static long ___L__2058__eval_2El__742[] = {

static long ___L__2059__eval_2El__742[] = {
  "illegal character escape: \\%c"
,
    _acc = (oop)___L__2059__eval_2El__742;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _fatal1;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__2056__eval_2El__741;

static long ___L__2055__eval_2El__741[] = {
  _acc = _tmp0;

static long ___L__2056__eval_2El__741[] = {

static long ___L__2039__eval_2El__705[] = {

static long ___L__2023__eval_2El__705[] = {

static long ___L__2009__eval_2El__705[] = {

static long ___L__2005__eval_2El__705[] = {

static long ___L__2001__eval_2El__705[] = {

static long ___L__1997__eval_2El__705[] = {

static long ___L__1993__eval_2El__705[] = {

static long ___L__1989__eval_2El__705[] = {

static long ___L__1985__eval_2El__705[] = {

static long ___L__1981__eval_2El__705[] = {
  goto ___L__1976__eval_2El__702;

static long ___L__1975__eval_2El__702[] = {
  _acc = _tmp0;

static long ___L__1976__eval_2El__702[] = {
return _acc;
}

oop read_char = (oop)read_char;
## defn digit_value
oop digit_value(oop _param0) {
  oop _acc = nil;

static long ___L__2060__eval_2El__695[] = {

static long ___L__2063__eval_2El__696[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(48);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2064__eval_2El__696;
  _acc = LONG(57);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2064__eval_2El__696[] = {
  if (_acc == nil) goto ___L__2061__eval_2El__695;
  _acc = LONG(48);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) - getLong(_tmp0));
  goto ___L__2062__eval_2El__695;

static long ___L__2061__eval_2El__695[] = {

static long ___L__2065__eval_2El__695[] = {

static long ___L__2068__eval_2El__697[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(97);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2069__eval_2El__697;
  _acc = LONG(122);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2069__eval_2El__697[] = {
  if (_acc == nil) goto ___L__2066__eval_2El__695;
  _acc = LONG(10);
  _tmp0 = _acc;
  _acc = LONG(97);
  _acc = LONG(getLong(_acc) - getLong(_tmp0));
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) - getLong(_tmp0));
  goto ___L__2067__eval_2El__695;

static long ___L__2066__eval_2El__695[] = {

static long ___L__2070__eval_2El__695[] = {

static long ___L__2073__eval_2El__698[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(65);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2074__eval_2El__698;
  _acc = LONG(90);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2074__eval_2El__698[] = {
  if (_acc == nil) goto ___L__2071__eval_2El__695;
  _acc = LONG(10);
  _tmp0 = _acc;
  _acc = LONG(65);
  _acc = LONG(getLong(_acc) - getLong(_tmp0));
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) - getLong(_tmp0));
  goto ___L__2072__eval_2El__695;

static long ___L__2071__eval_2El__695[] = {

static long ___L__2075__eval_2El__699[] = {

static long ___L__2076__eval_2El__699[] = {
  "illegal digit in character escape"
,
    _acc = (oop)___L__2076__eval_2El__699;
  _tmp0 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2072__eval_2El__695[] = {

static long ___L__2067__eval_2El__695[] = {

static long ___L__2062__eval_2El__695[] = {
return _acc;
}

oop digit_value = (oop)digit_value;
## defn is_hexadecimal
oop is_hexadecimal(oop _param0) {
  oop _acc = nil;

static long ___L__2077__eval_2El__690[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(48);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2079__eval_2El__690;
  _acc = LONG(57);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2079__eval_2El__690[] = {
  if (_acc != nil) goto ___L__2078__eval_2El__690;

static long ___L__2080__eval_2El__691[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(97);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2081__eval_2El__691;
  _acc = LONG(102);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2081__eval_2El__691[] = {
  if (_acc != nil) goto ___L__2078__eval_2El__690;

static long ___L__2082__eval_2El__692[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(65);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2083__eval_2El__692;
  _acc = LONG(70);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2083__eval_2El__692[] = {

static long ___L__2078__eval_2El__690[] = {
return _acc;
}

oop is_hexadecimal = (oop)is_hexadecimal;
## defn is_octal
oop is_octal(oop _param0) {
  oop _acc = nil;

static long ___L__2084__eval_2El__688[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(48);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2085__eval_2El__688;
  _acc = LONG(55);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2085__eval_2El__688[] = {
return _acc;
}

oop is_octal = (oop)is_octal;
## defn intern
oop intern(oop _param0) {
  oop _acc = nil;

static long ___L__2086__eval_2El__675[] = {
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__2087__eval_2El__676[] = {
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _symbols;
  _tmp2 = _acc;
  _acc = _k__array__length;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = LONG(getLong(_acc) - getLong(_tmp1));
  _tmp1 = _acc;

static long ___L__2088__eval_2El__677[] = {
  goto ___L__2090__eval_2El__677;

static long ___L__2089__eval_2El__677[] = {

static long ___L__2091__eval_2El__678[] = {
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) + getLong(_tmp3));
  _acc = LONG(getLong(_acc) / getLong(_tmp2));
  _tmp2 = _acc;

static long ___L__2092__eval_2El__679[] = {
  _acc = _symbols;
  _tmp3 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = _k__array__at;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp4 = _acc;

static long ___L__2093__eval_2El__678[] = {

static long ___L__2094__eval_2El__680[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _tmp4;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Csymbol_3E;
  _tmp7 = _acc;
  _acc = _tmp5;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp5 = _acc;
  _acc = _strcmp_24stub;
  _tmp0 = _tmp3;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp5 = _acc;

static long ___L__2095__eval_2El__681[] = {

static long ___L__2098__eval_2El__682[] = {
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = _tmp5;
  _acc = (getLong(_acc) < getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2096__eval_2El__681;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) - getLong(_tmp3));
  _tmp1 = _acc;
  goto ___L__2097__eval_2El__681;

static long ___L__2096__eval_2El__681[] = {

static long ___L__2099__eval_2El__681[] = {

static long ___L__2102__eval_2El__683[] = {
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = _tmp5;
  _acc = (getLong(_acc) > getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2100__eval_2El__681;
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) + getLong(_tmp3));
  _tmp0 = _acc;
  goto ___L__2101__eval_2El__681;

static long ___L__2100__eval_2El__681[] = {

static long ___L__2103__eval_2El__684[] = {
  _acc = _tmp4;
  goto ___L__2104__eval_2El__684;

static long ___L__2101__eval_2El__681[] = {

static long ___L__2097__eval_2El__681[] = {

static long ___L__2090__eval_2El__677[] = {

static long ___L__2105__eval_2El__677[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2089__eval_2El__677;

static long ___L__2106__eval_2El__685[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _new_2D_3Csymbol_3E;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;
  _acc = (oop)&_tmp2;
  _tmp4 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2107__eval_2El__686[] = {
  _acc = _symbols;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = _k__array__insert;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp3 = _acc;

static long ___L__2108__eval_2El__685[] = {
  _acc = (oop)&_tmp2;
  _tmp5 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp3;
___L__2104__eval_2El__684:
  return _acc;
}

oop intern = (oop)intern;
## defn buffer_contents
oop buffer_contents(oop _param0) {
  oop _acc = nil;

static long ___L__2109__eval_2El__670[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _buffer__append;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2110__eval_2El__671[] = {
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = LONG(2);
  _tmp0 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _acc = LONG(getLong(_acc) - getLong(_tmp1));
  _tmp1 = _acc;
  _acc = LONG(2);
  _tmp0 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp0)] = _tmp1;

static long ___L__2111__eval_2El__672[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
return _acc;
}

oop buffer_contents = (oop)buffer_contents;
## defn buffer_append_all
oop buffer_append_all(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2112__eval_2El__663[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp1 = _acc;

static long ___L__2113__eval_2El__665[] = {
  goto ___L__2115__eval_2El__665;

static long ___L__2114__eval_2El__665[] = {

static long ___L__2116__eval_2El__666[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _buffer__append;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2117__eval_2El__667[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(1);
  _acc = LONG(getLong(_acc) + getLong(_tmp3));
  _tmp0 = _acc;

static long ___L__2115__eval_2El__665[] = {

static long ___L__2118__eval_2El__665[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = LONG(((char*)_acc)[getLong(_tmp3)]);
  _tmp1 = _acc;
  if (_acc != nil) goto ___L__2114__eval_2El__665;
return _acc;
}

oop buffer_append_all = (oop)buffer_append_all;
## defn buffer_append
oop buffer_append(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2119__eval_2El__656[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2120__eval_2El__656;

static long ___L__2121__eval_2El__657[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _buffer__grow;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2120__eval_2El__656[] = {

static long ___L__2122__eval_2El__658[] = {
  _acc = LONG(2);
  _tmp0 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__2123__eval_2El__659[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  ((char*)_acc)[getLong(_tmp2)] = (char)getLong(_tmp3);

static long ___L__2124__eval_2El__660[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(1);
  _acc = LONG(getLong(_acc) + getLong(_tmp3));
  _tmp3 = _acc;
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp3;
return _acc;
}

oop buffer_append = (oop)buffer_append;
## defn buffer_grow
oop buffer_grow(oop _param0) {
  oop _acc = nil;

static long ___L__2125__eval_2El__648[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;

static long ___L__2126__eval_2El__649[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(2);
  _acc = LONG(getLong(_acc) * getLong(_tmp2));
  _tmp2 = _acc;
  _acc = _malloc_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp2 = _acc;

static long ___L__2127__eval_2El__650[] = {
  _acc = _tmp2;
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _memcpy_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp3;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__2128__eval_2El__651[] = {
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp5 = _acc;
  _acc = _free_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2129__eval_2El__652[] = {
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp1)] = _tmp5;

static long ___L__2130__eval_2El__653[] = {
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = LONG(2);
  _acc = LONG(getLong(_acc) * getLong(_tmp5));
  _tmp5 = _acc;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp1)] = _tmp5;
return _acc;
}

oop buffer_grow = (oop)buffer_grow;
## defn buffer_delete
oop buffer_delete(oop _param0) {
  oop _acc = nil;

static long ___L__2131__eval_2El__644[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _free_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2132__eval_2El__645[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _free_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop buffer_delete = (oop)buffer_delete;
## defn new_buffer
oop new_buffer() {
  oop _acc = nil;

static long ___L__2133__eval_2El__637[] = {
  _acc = LONG(12);
  _tmp0 = _acc;
  _acc = _malloc_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__2134__eval_2El__638[] = {
  _acc = LONG(32);
  _tmp1 = _acc;
  _acc = _malloc_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp1;

static long ___L__2135__eval_2El__639[] = {
  _acc = LONG(32);
  _tmp1 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp1;

static long ___L__2136__eval_2El__640[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = __3Cbuffer_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp1;
  _acc = _tmp0;
return _acc;
}

oop new_buffer = (oop)new_buffer;
## defn is_letter
oop is_letter(oop _param0) {
  oop _acc = nil;

static long ___L__2137__eval_2El__623[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(33);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2138__eval_2El__623;

static long ___L__2139__eval_2El__624[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(35);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2140__eval_2El__624;
  _acc = LONG(38);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2140__eval_2El__624[] = {
  if (_acc != nil) goto ___L__2138__eval_2El__623;

static long ___L__2141__eval_2El__625[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(42);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2142__eval_2El__625;
  _acc = LONG(47);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2142__eval_2El__625[] = {
  if (_acc != nil) goto ___L__2138__eval_2El__623;

static long ___L__2143__eval_2El__626[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(58);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2138__eval_2El__623;

static long ___L__2144__eval_2El__627[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(60);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2145__eval_2El__627;
  _acc = LONG(90);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2145__eval_2El__627[] = {
  if (_acc != nil) goto ___L__2138__eval_2El__623;

static long ___L__2146__eval_2El__628[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(92);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2138__eval_2El__623;

static long ___L__2147__eval_2El__629[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(94);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2138__eval_2El__623;

static long ___L__2148__eval_2El__630[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(95);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2138__eval_2El__623;

static long ___L__2149__eval_2El__631[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(97);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2150__eval_2El__631;
  _acc = LONG(122);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2150__eval_2El__631[] = {
  if (_acc != nil) goto ___L__2138__eval_2El__623;

static long ___L__2151__eval_2El__632[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(124);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2138__eval_2El__623;

static long ___L__2152__eval_2El__633[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(126);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2138__eval_2El__623;

static long ___L__2153__eval_2El__634[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(128);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2138__eval_2El__623[] = {
return _acc;
}

oop is_letter = (oop)is_letter;
## defn is_alpha
oop is_alpha(oop _param0) {
  oop _acc = nil;

static long ___L__2154__eval_2El__620[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(97);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2156__eval_2El__620;
  _acc = LONG(122);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2156__eval_2El__620[] = {
  if (_acc != nil) goto ___L__2155__eval_2El__620;

static long ___L__2157__eval_2El__621[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(65);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2158__eval_2El__621;
  _acc = LONG(90);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2158__eval_2El__621[] = {

static long ___L__2155__eval_2El__620[] = {
return _acc;
}

oop is_alpha = (oop)is_alpha;
## defn is_digit16
oop is_digit16(oop _param0) {
  oop _acc = nil;

static long ___L__2159__eval_2El__616[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(48);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2161__eval_2El__616;
  _acc = LONG(57);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2161__eval_2El__616[] = {
  if (_acc != nil) goto ___L__2160__eval_2El__616;

static long ___L__2162__eval_2El__617[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(97);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2163__eval_2El__617;
  _acc = LONG(102);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2163__eval_2El__617[] = {
  if (_acc != nil) goto ___L__2160__eval_2El__616;

static long ___L__2164__eval_2El__618[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(65);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2165__eval_2El__618;
  _acc = LONG(70);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2165__eval_2El__618[] = {

static long ___L__2160__eval_2El__616[] = {
return _acc;
}

oop is_digit16 = (oop)is_digit16;
## defn is_digit10
oop is_digit10(oop _param0) {
  oop _acc = nil;

static long ___L__2166__eval_2El__614[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(48);
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2167__eval_2El__614;
  _acc = LONG(57);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) <= getLong(_tmp0)) ? LONG(1) : LONG(0);

static long ___L__2167__eval_2El__614[] = {
return _acc;
}

oop is_digit10 = (oop)is_digit10;
## defn is_blank
oop is_blank(oop _param0) {
  oop _acc = nil;

static long ___L__2168__eval_2El__607[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(32);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2169__eval_2El__607;

static long ___L__2170__eval_2El__608[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(9);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2169__eval_2El__607;

static long ___L__2171__eval_2El__609[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(10);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2169__eval_2El__607;

static long ___L__2172__eval_2El__610[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(11);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2169__eval_2El__607;

static long ___L__2173__eval_2El__611[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(12);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2169__eval_2El__607;

static long ___L__2174__eval_2El__612[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(13);
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);

static long ___L__2169__eval_2El__607[] = {
return _acc;
}

oop is_blank = (oop)is_blank;
## defn k_dumpln
oop k_dumpln(oop _param0) {
  oop _acc = nil;

static long ___L__2175__eval_2El__596[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _do__print;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2176__eval_2El__596[] = {
  "\012"
,
    _acc = (oop)___L__2176__eval_2El__596;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop k_dumpln = (oop)k_dumpln;
## defn k_dump
oop k_dump(oop _param0) {
  oop _acc = nil;
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _do__print;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
return _acc;
}

oop k_dump = (oop)k_dump;
## defn k_println
oop k_println(oop _param0) {
  oop _acc = nil;

static long ___L__2177__eval_2El__595[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _do__print;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2178__eval_2El__595[] = {
  "\012"
,
    _acc = (oop)___L__2178__eval_2El__595;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop k_println = (oop)k_println;
## defn k_print
oop k_print(oop _param0) {
  oop _acc = nil;
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _do__print;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
return _acc;
}

oop k_print = (oop)k_print;
## defn do_print
oop do_print(oop _param0, oop _param1) {
  oop _acc = nil;
  _acc = LONG(0);

static long ___L__2179__eval_2El__530[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__2180__eval_2El__530;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__2182__eval_2El__530;
  _acc = __3Clong_3E;
  goto ___L__2183__eval_2El__530;

static long ___L__2182__eval_2El__530[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__2183__eval_2El__530[] = {
  goto ___L__2181__eval_2El__530;

static long ___L__2180__eval_2El__530[] = {
  _acc = __3Cundefined_3E;

static long ___L__2181__eval_2El__530[] = {
  _tmp0 = _acc;

static long ___L__2184__eval_2El__531[] = {

static long ___L__2187__eval_2El__532[] = {
  _acc = __3Cundefined_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2185__eval_2El__531;

static long ___L__2188__eval_2El__532[] = {
  "nil"
,
    _acc = (oop)___L__2188__eval_2El__532;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__2186__eval_2El__531;

static long ___L__2185__eval_2El__531[] = {

static long ___L__2189__eval_2El__531[] = {

static long ___L__2192__eval_2El__533[] = {
  _acc = __3Clong_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2190__eval_2El__531;

static long ___L__2193__eval_2El__533[] = {
  "%d"
,
    _acc = (oop)___L__2193__eval_2El__533;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__2191__eval_2El__531;

static long ___L__2190__eval_2El__531[] = {

static long ___L__2194__eval_2El__531[] = {

static long ___L__2197__eval_2El__534[] = {
  _acc = __3Cstring_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2195__eval_2El__531;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = __3Cstring_3E;
  _tmp3 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp2 = _acc;

static long ___L__2198__eval_2El__535[] = {
  _acc = _tmp1;
  _acc = (_acc == nil) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2199__eval_2El__535;

static long ___L__2201__eval_2El__536[] = {

static long ___L__2202__eval_2El__536[] = {
  "%s"
,
    _acc = (oop)___L__2202__eval_2El__536;
  _tmp1 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__2200__eval_2El__535;

static long ___L__2199__eval_2El__535[] = {

static long ___L__2203__eval_2El__537[] = {
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = LONG(0);
  _tmp1 = _acc;

static long ___L__2204__eval_2El__539[] = {

static long ___L__2205__eval_2El__539[] = {
  "\""
,
    _acc = (oop)___L__2205__eval_2El__539;
  _tmp3 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2206__eval_2El__540[] = {
  goto ___L__2208__eval_2El__540;

static long ___L__2207__eval_2El__540[] = {

static long ___L__2209__eval_2El__541[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(32);
  _acc = (getLong(_acc) <= getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2212__eval_2El__541;
  _acc = LONG(126);
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = (getLong(_acc) <= getLong(_tmp3)) ? LONG(1) : LONG(0);

static long ___L__2212__eval_2El__541[] = {
  if (_acc == nil) goto ___L__2210__eval_2El__541;

static long ___L__2213__eval_2El__542[] = {

static long ___L__2216__eval_2El__543[] = {
  _acc = LONG(34);
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2214__eval_2El__542;

static long ___L__2217__eval_2El__543[] = {
  "\\\""
,
    _acc = (oop)___L__2217__eval_2El__543;
  _tmp3 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__2215__eval_2El__542;

static long ___L__2214__eval_2El__542[] = {

static long ___L__2218__eval_2El__542[] = {

static long ___L__2221__eval_2El__544[] = {
  _acc = LONG(92);
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2219__eval_2El__542;

static long ___L__2222__eval_2El__544[] = {
  "\\\\"
,
    _acc = (oop)___L__2222__eval_2El__544;
  _tmp3 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__2220__eval_2El__542;

static long ___L__2219__eval_2El__542[] = {

static long ___L__2223__eval_2El__545[] = {

static long ___L__2224__eval_2El__545[] = {
  "%c"
,
    _acc = (oop)___L__2224__eval_2El__545;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2220__eval_2El__542[] = {

static long ___L__2215__eval_2El__542[] = {
  goto ___L__2211__eval_2El__541;

static long ___L__2210__eval_2El__541[] = {

static long ___L__2225__eval_2El__546[] = {

static long ___L__2226__eval_2El__546[] = {
  "\\%03o"
,
    _acc = (oop)___L__2226__eval_2El__546;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2211__eval_2El__541[] = {

static long ___L__2227__eval_2El__547[] = {
  _acc = _tmp5;
  _tmp3 = _acc;
  _acc = LONG(1);
  _acc = LONG(getLong(_acc) + getLong(_tmp3));
  _tmp5 = _acc;

static long ___L__2208__eval_2El__540[] = {

static long ___L__2228__eval_2El__540[] = {
  _acc = _tmp5;
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(((char*)_acc)[getLong(_tmp3)]);
  _tmp1 = _acc;
  if (_acc != nil) goto ___L__2207__eval_2El__540;

static long ___L__2229__eval_2El__548[] = {

static long ___L__2230__eval_2El__548[] = {
  "\""
,
    _acc = (oop)___L__2230__eval_2El__548;
  _tmp3 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2200__eval_2El__535[] = {
  goto ___L__2196__eval_2El__531;

static long ___L__2195__eval_2El__531[] = {

static long ___L__2231__eval_2El__531[] = {

static long ___L__2234__eval_2El__549[] = {
  _acc = __3Csymbol_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2232__eval_2El__531;

static long ___L__2235__eval_2El__549[] = {
  "%s"
,
    _acc = (oop)___L__2235__eval_2El__549;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Csymbol_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__2233__eval_2El__531;

static long ___L__2232__eval_2El__531[] = {

static long ___L__2236__eval_2El__531[] = {

static long ___L__2239__eval_2El__550[] = {
  _acc = __3Cpair_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2237__eval_2El__531;

static long ___L__2240__eval_2El__551[] = {

static long ___L__2241__eval_2El__551[] = {
  "("
,
    _acc = (oop)___L__2241__eval_2El__551;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2242__eval_2El__552[] = {
  goto ___L__2244__eval_2El__552;

static long ___L__2243__eval_2El__552[] = {

static long ___L__2245__eval_2El__553[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _do__print;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2246__eval_2El__554[] = {
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp0 = _acc;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__2248__eval_2El__554;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__2250__eval_2El__554;
  _acc = __3Clong_3E;
  goto ___L__2251__eval_2El__554;

static long ___L__2250__eval_2El__554[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__2251__eval_2El__554[] = {
  goto ___L__2249__eval_2El__554;

static long ___L__2248__eval_2El__554[] = {
  _acc = __3Cundefined_3E;

static long ___L__2249__eval_2El__554[] = {
  _tmp2 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2247__eval_2El__554;

static long ___L__2252__eval_2El__554[] = {
  " "
,
    _acc = (oop)___L__2252__eval_2El__554;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2247__eval_2El__554[] = {

static long ___L__2244__eval_2El__552[] = {

static long ___L__2253__eval_2El__552[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  if (_acc == nil) goto ___L__2255__eval_2El__552;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__2257__eval_2El__552;
  _acc = __3Clong_3E;
  goto ___L__2258__eval_2El__552;

static long ___L__2257__eval_2El__552[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp2;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__2258__eval_2El__552[] = {
  goto ___L__2256__eval_2El__552;

static long ___L__2255__eval_2El__552[] = {
  _acc = __3Cundefined_3E;

static long ___L__2256__eval_2El__552[] = {
  _tmp2 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2254__eval_2El__552;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _globals;
  _acc = (_acc != _tmp2) ? LONG(1) : LONG(0);

static long ___L__2254__eval_2El__552[] = {
  if (_acc != nil) goto ___L__2243__eval_2El__552;

static long ___L__2259__eval_2El__555[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _globals;
  _acc = (_acc == _tmp2) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2260__eval_2El__555;

static long ___L__2262__eval_2El__556[] = {

static long ___L__2263__eval_2El__556[] = {
  "<globals>"
,
    _acc = (oop)___L__2263__eval_2El__556;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__2261__eval_2El__555;

static long ___L__2260__eval_2El__555[] = {

static long ___L__2264__eval_2El__557[] = {
  _acc = _tmp0;
  if (_acc == nil) goto ___L__2265__eval_2El__557;

static long ___L__2266__eval_2El__558[] = {

static long ___L__2267__eval_2El__559[] = {

static long ___L__2268__eval_2El__559[] = {
  " . "
,
    _acc = (oop)___L__2268__eval_2El__559;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2269__eval_2El__560[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _do__print;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2265__eval_2El__557[] = {

static long ___L__2261__eval_2El__555[] = {

static long ___L__2270__eval_2El__561[] = {

static long ___L__2271__eval_2El__561[] = {
  ")"
,
    _acc = (oop)___L__2271__eval_2El__561;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__2238__eval_2El__531;

static long ___L__2237__eval_2El__531[] = {

static long ___L__2272__eval_2El__531[] = {

static long ___L__2275__eval_2El__562[] = {
  _acc = __3Carray_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2273__eval_2El__531;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__array__length;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__2276__eval_2El__563[] = {

static long ___L__2277__eval_2El__563[] = {
  "Array("
,
    _acc = (oop)___L__2277__eval_2El__563;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2278__eval_2El__564[] = {
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp5 = _acc;
  goto ___L__2280__eval_2El__564;

static long ___L__2279__eval_2El__564[] = {

static long ___L__2281__eval_2El__565[] = {
  _acc = _tmp2;
  if (_acc == nil) goto ___L__2282__eval_2El__565;

static long ___L__2283__eval_2El__565[] = {
  " "
,
    _acc = (oop)___L__2283__eval_2El__565;
  _tmp4 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2282__eval_2El__565[] = {

static long ___L__2284__eval_2El__566[] = {
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = _k__array__at;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp3 = _acc;
  _acc = _do__print;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2285__eval_2El__564[] = {
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) + getLong(_tmp3));
  _tmp2 = _acc;

static long ___L__2280__eval_2El__564[] = {
  _acc = _tmp5;
  _tmp3 = _acc;
  _acc = _tmp2;
  _acc = (getLong(_acc) < getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2279__eval_2El__564;

static long ___L__2286__eval_2El__567[] = {

static long ___L__2287__eval_2El__567[] = {
  ")"
,
    _acc = (oop)___L__2287__eval_2El__567;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__2274__eval_2El__531;

static long ___L__2273__eval_2El__531[] = {

static long ___L__2288__eval_2El__531[] = {

static long ___L__2291__eval_2El__568[] = {
  _acc = __3Cexpr_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2289__eval_2El__531;

static long ___L__2292__eval_2El__569[] = {

static long ___L__2293__eval_2El__569[] = {
  "Expr("
,
    _acc = (oop)___L__2293__eval_2El__569;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2294__eval_2El__570[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = __3Cexpr_3E;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp1 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _do__print;
  _tmp0 = _tmp1;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2295__eval_2El__571[] = {

static long ___L__2296__eval_2El__571[] = {
  ")"
,
    _acc = (oop)___L__2296__eval_2El__571;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__2290__eval_2El__531;

static long ___L__2289__eval_2El__531[] = {

static long ___L__2297__eval_2El__531[] = {

static long ___L__2300__eval_2El__572[] = {
  _acc = __3Cform_3E;
  _tmp5 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp5) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2298__eval_2El__531;

static long ___L__2301__eval_2El__573[] = {

static long ___L__2302__eval_2El__573[] = {
  "Form("
,
    _acc = (oop)___L__2302__eval_2El__573;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2303__eval_2El__574[] = {
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Cform_3E;
  _tmp3 = _acc;
  _acc = _tmp5;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp5 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _do__print;
  _tmp0 = _tmp5;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2304__eval_2El__575[] = {

static long ___L__2305__eval_2El__575[] = {
  ","
,
    _acc = (oop)___L__2305__eval_2El__575;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2306__eval_2El__576[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp5 = _acc;
  _acc = __3Cform_3E;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp5)];
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _do__print;
  _tmp0 = _tmp1;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2307__eval_2El__577[] = {

static long ___L__2308__eval_2El__577[] = {
  ")"
,
    _acc = (oop)___L__2308__eval_2El__577;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__2299__eval_2El__531;

static long ___L__2298__eval_2El__531[] = {

static long ___L__2309__eval_2El__531[] = {

static long ___L__2312__eval_2El__578[] = {
  _acc = __3Cfixed_3E;
  _tmp5 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp5) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2310__eval_2El__531;

static long ___L__2313__eval_2El__579[] = {

static long ___L__2314__eval_2El__579[] = {
  "Fixed("
,
    _acc = (oop)___L__2314__eval_2El__579;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2315__eval_2El__580[] = {
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Cfixed_3E;
  _tmp3 = _acc;
  _acc = _tmp5;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp5 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _do__print;
  _tmp0 = _tmp5;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2316__eval_2El__581[] = {

static long ___L__2317__eval_2El__581[] = {
  ")"
,
    _acc = (oop)___L__2317__eval_2El__581;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__2311__eval_2El__531;

static long ___L__2310__eval_2El__531[] = {

static long ___L__2318__eval_2El__531[] = {

static long ___L__2321__eval_2El__582[] = {
  _acc = __3Csubr_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2319__eval_2El__531;

static long ___L__2322__eval_2El__582[] = {
  "Subr(%s)"
,
    _acc = (oop)___L__2322__eval_2El__582;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Csubr_3E;
  _tmp3 = _acc;
  _acc = _tmp5;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__2320__eval_2El__531;

static long ___L__2319__eval_2El__531[] = {

static long ___L__2323__eval_2El__531[] = {

static long ___L__2326__eval_2El__583[] = {
  _acc = __3Cvariable_3E;
  _tmp5 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp5) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2324__eval_2El__531;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp1 = _acc;
  _acc = __3Cvariable_3E;
  _tmp2 = _acc;
  _acc = _tmp5;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp5 = _acc;

static long ___L__2327__eval_2El__584[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = __3Cvariable_3E;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp1 = _acc;
  _acc = _do__print;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2328__eval_2El__585[] = {
  _acc = _tmp5;
  if (_acc == nil) goto ___L__2329__eval_2El__585;

static long ___L__2330__eval_2El__586[] = {

static long ___L__2331__eval_2El__586[] = {
  ".%d+%d"
,
    _acc = (oop)___L__2331__eval_2El__586;
  _tmp1 = _acc;

static long ___L__2332__eval_2El__587[] = {
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp3 = _acc;
  _acc = __3Cvariable_3E;
  _tmp2 = _acc;
  _acc = _tmp4;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = __3Cenv_3E;
  _tmp6 = _acc;
  _acc = _tmp4;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp2 = _acc;
  _acc = _tmp4;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp4 = _acc;

static long ___L__2333__eval_2El__588[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(3);
  _tmp6 = _acc;
  _acc = __3Cvariable_3E;
  _tmp2 = _acc;
  _acc = _tmp3;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Clong_3E;
  _tmp7 = _acc;
  _acc = _tmp3;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp3 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp4;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__2329__eval_2El__585[] = {
  goto ___L__2325__eval_2El__531;

static long ___L__2324__eval_2El__531[] = {

static long ___L__2334__eval_2El__531[] = {

static long ___L__2337__eval_2El__589[] = {
  _acc = __3Cenv_3E;
  _tmp5 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp5) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2335__eval_2El__531;

static long ___L__2338__eval_2El__590[] = {

static long ___L__2339__eval_2El__590[] = {
  "Env<%d>"
,
    _acc = (oop)___L__2339__eval_2El__590;
  _tmp5 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cenv_3E;
  _tmp1 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = __3Clong_3E;
  _tmp6 = _acc;
  _acc = _tmp3;
  _tmp1 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp3 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp5;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  goto ___L__2336__eval_2El__531;

static long ___L__2335__eval_2El__531[] = {

static long ___L__2340__eval_2El__531[] = {

static long ___L__2343__eval_2El__591[] = {
  _acc = __3Ccontext_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2341__eval_2El__531;

static long ___L__2344__eval_2El__592[] = {

static long ___L__2345__eval_2El__592[] = {
  "Context<>"
,
    _acc = (oop)___L__2345__eval_2El__592;
  _tmp3 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);
  goto ___L__2342__eval_2El__531;

static long ___L__2341__eval_2El__531[] = {

static long ___L__2346__eval_2El__593[] = {

static long ___L__2347__eval_2El__593[] = {
  "<type:%d>"
,
    _acc = (oop)___L__2347__eval_2El__593;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp3;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2342__eval_2El__531[] = {

static long ___L__2336__eval_2El__531[] = {

static long ___L__2325__eval_2El__531[] = {

static long ___L__2320__eval_2El__531[] = {

static long ___L__2311__eval_2El__531[] = {

static long ___L__2299__eval_2El__531[] = {

static long ___L__2290__eval_2El__531[] = {

static long ___L__2274__eval_2El__531[] = {

static long ___L__2238__eval_2El__531[] = {

static long ___L__2233__eval_2El__531[] = {

static long ___L__2196__eval_2El__531[] = {

static long ___L__2191__eval_2El__531[] = {

static long ___L__2186__eval_2El__531[] = {
return _acc;
}

oop do_print = (oop)do_print;
## defn k_array_insert
oop k_array_insert(oop _param0, oop _param1, oop _param2) {
  oop _acc = nil;

static long ___L__2348__eval_2El__520[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__array__length;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__2349__eval_2El__521[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp2;
  _tmp2 = _acc;
  _acc = _k__array__append;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2350__eval_2El__522[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _tmp1;
  _acc = (getLong(_acc) < getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2351__eval_2El__522;

static long ___L__2352__eval_2El__523[] = {
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = __3Carray_3E;
  _tmp3 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp2 = _acc;

static long ___L__2353__eval_2El__524[] = {
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = LONG(4);
  _acc = LONG(getLong(_acc) * getLong(_tmp1));
  _tmp1 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) + getLong(_tmp1));
  _tmp1 = _acc;

static long ___L__2354__eval_2El__525[] = {
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = LONG(4);
  _acc = LONG(getLong(_acc) + getLong(_tmp4));
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) - getLong(_tmp5));
  _tmp5 = _acc;
  _acc = LONG(4);
  _acc = LONG(getLong(_acc) * getLong(_tmp5));
  _tmp5 = _acc;
  _acc = _memmove_24stub;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _tmp2 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__2351__eval_2El__522[] = {

static long ___L__2355__eval_2El__526[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _tmp2;
  _tmp1 = _acc;
  _acc = _k__set__array__at;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _tmp2 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
return _acc;
}

oop k_array_insert = (oop)k_array_insert;
## defn k_array_append
oop k_array_append(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2356__eval_2El__517[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__array__length;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _k__set__array__at;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _tmp2 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
return _acc;
}

oop k_array_append = (oop)k_array_append;
## defn k_set_array_at
oop k_set_array_at(oop _param0, oop _param1, oop _param2) {
  oop _acc = nil;

static long ___L__2357__eval_2El__501[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__2359__eval_2El__501;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__2361__eval_2El__501;
  _acc = __3Clong_3E;
  goto ___L__2362__eval_2El__501;

static long ___L__2361__eval_2El__501[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__2362__eval_2El__501[] = {
  goto ___L__2360__eval_2El__501;

static long ___L__2359__eval_2El__501[] = {
  _acc = __3Cundefined_3E;

static long ___L__2360__eval_2El__501[] = {
  _tmp0 = _acc;
  _acc = __3Carray_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2358__eval_2El__501;

static long ___L__2363__eval_2El__502[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = __3Carray_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp0 = _acc;

static long ___L__2364__eval_2El__503[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Carray_3E;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp1 = _acc;

static long ___L__2365__eval_2El__504[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = (getLong(_acc) <= getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2366__eval_2El__504;

static long ___L__2367__eval_2El__505[] = {

static long ___L__2368__eval_2El__506[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = (getLong(_acc) < getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2369__eval_2El__506;

static long ___L__2370__eval_2El__507[] = {
  _acc = LONG(4);
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _gc__size;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = LONG(getLong(_acc) / getLong(_tmp3));
  _tmp3 = _acc;

static long ___L__2371__eval_2El__508[] = {
  goto ___L__2373__eval_2El__508;

static long ___L__2372__eval_2El__508[] = {
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) * getLong(_tmp2));
  _tmp3 = _acc;

static long ___L__2373__eval_2El__508[] = {
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _tmp3;
  _acc = (getLong(_acc) <= getLong(_tmp2)) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2372__eval_2El__508;

static long ___L__2374__eval_2El__509[] = {
  _acc = (oop)&_tmp0;
  _tmp2 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2375__eval_2El__510[] = {
  _acc = __3C__array_3E;
  _tmp2 = _acc;
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = LONG(4);
  _acc = LONG(getLong(_acc) * getLong(_tmp4));
  _tmp4 = _acc;
  _acc = _new_2Doops;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp4 = _acc;

static long ___L__2376__eval_2El__511[] = {
  _acc = _tmp4;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = LONG(4);
  _tmp6 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) * getLong(_tmp6));
  _tmp6 = _acc;
  _acc = _memcpy_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp5;
  _tmp2 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__2377__eval_2El__512[] = {
  _acc = _tmp0;
  _tmp6 = _acc;
  _acc = LONG(0);
  _acc = _tmp4;
  _tmp5 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Carray_3E;
  _tmp7 = _acc;
  _acc = _tmp6;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp5;
  _tmp0 = _acc;

static long ___L__2378__eval_2El__513[] = {
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = _tmp1;
  _tmp6 = _acc;
  _acc = LONG(1);
  _acc = LONG(getLong(_acc) + getLong(_tmp6));
  _tmp6 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp6 = _acc;
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = __3Carray_3E;
  _tmp2 = _acc;
  _acc = _tmp4;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp5)] = _tmp6;
  _tmp4 = _acc;

static long ___L__2379__eval_2El__509[] = {
  _acc = (oop)&_tmp0;
  _tmp6 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp4;

static long ___L__2369__eval_2El__506[] = {

static long ___L__2380__eval_2El__514[] = {
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _tmp0;
  ((oop*)_acc)[getLong(_tmp4)] = _tmp3;

static long ___L__2366__eval_2El__504[] = {

static long ___L__2358__eval_2El__501[] = {
return _acc;
}

oop k_set_array_at = (oop)k_set_array_at;
## defn k_array_at
oop k_array_at(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2381__eval_2El__494[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__2383__eval_2El__494;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__2385__eval_2El__494;
  _acc = __3Clong_3E;
  goto ___L__2386__eval_2El__494;

static long ___L__2385__eval_2El__494[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__2386__eval_2El__494[] = {
  goto ___L__2384__eval_2El__494;

static long ___L__2383__eval_2El__494[] = {
  _acc = __3Cundefined_3E;

static long ___L__2384__eval_2El__494[] = {
  _tmp0 = _acc;
  _acc = __3Carray_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2382__eval_2El__494;

static long ___L__2387__eval_2El__495[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = __3Carray_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp0 = _acc;

static long ___L__2388__eval_2El__496[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Carray_3E;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp1 = _acc;

static long ___L__2389__eval_2El__497[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = (getLong(_acc) <= getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2390__eval_2El__497;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = (getLong(_acc) < getLong(_tmp3)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2390__eval_2El__497;

static long ___L__2391__eval_2El__498[] = {
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp3)];

static long ___L__2390__eval_2El__497[] = {

static long ___L__2382__eval_2El__494[] = {
return _acc;
}

oop k_array_at = (oop)k_array_at;
## defn k_array_length
oop k_array_length(oop _param0) {
  oop _acc = nil;

static long ___L__2392__eval_2El__491[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Carray_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Clong_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
return _acc;
}

oop k_array_length = (oop)k_array_length;
## defn k_concat
oop k_concat(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2393__eval_2El__483[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__2396__eval_2El__483;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__2398__eval_2El__483;
  _acc = __3Clong_3E;
  goto ___L__2399__eval_2El__483;

static long ___L__2398__eval_2El__483[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__2399__eval_2El__483[] = {
  goto ___L__2397__eval_2El__483;

static long ___L__2396__eval_2El__483[] = {
  _acc = __3Cundefined_3E;

static long ___L__2397__eval_2El__483[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2394__eval_2El__483;

static long ___L__2400__eval_2El__484[] = {

static long ___L__2401__eval_2El__485[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _k__concat;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__2402__eval_2El__486[] = {
  _acc = (oop)&_tmp1;
  _tmp1 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2403__eval_2El__487[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _new_2D_3Cpair_3E;
  _tmp0 = _tmp1;
  _tmp1 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp0 = _acc;

static long ___L__2404__eval_2El__486[] = {
  _acc = (oop)&_tmp1;
  _tmp1 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  goto ___L__2395__eval_2El__483;

static long ___L__2394__eval_2El__483[] = {
  _acc = _tmp1;

static long ___L__2395__eval_2El__483[] = {
return _acc;
}

oop k_concat = (oop)k_concat;
## defn k_string_length
oop k_string_length(oop _param0) {
  oop _acc = nil;

static long ___L__2405__eval_2El__480[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Cstring_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = __3Clong_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
return _acc;
}

oop k_string_length = (oop)k_string_length;
## defn k_caddr
oop k_caddr(oop _param0) {
  oop _acc = nil;

static long ___L__2406__eval_2El__478[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__cdr;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _k__cdr;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop k_caddr = (oop)k_caddr;
## defn k_cddr
oop k_cddr(oop _param0) {
  oop _acc = nil;

static long ___L__2407__eval_2El__476[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__cdr;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _k__cdr;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop k_cddr = (oop)k_cddr;
## defn k_cadr
oop k_cadr(oop _param0) {
  oop _acc = nil;

static long ___L__2408__eval_2El__475[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__cdr;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop k_cadr = (oop)k_cadr;
## defn k_caar
oop k_caar(oop _param0) {
  oop _acc = nil;

static long ___L__2409__eval_2El__474[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = _k__car;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop k_caar = (oop)k_caar;
## defn k_cdr
oop k_cdr(oop _param0) {
  oop _acc = nil;

static long ___L__2410__eval_2El__472[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__2412__eval_2El__472;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__2414__eval_2El__472;
  _acc = __3Clong_3E;
  goto ___L__2415__eval_2El__472;

static long ___L__2414__eval_2El__472[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__2415__eval_2El__472[] = {
  goto ___L__2413__eval_2El__472;

static long ___L__2412__eval_2El__472[] = {
  _acc = __3Cundefined_3E;

static long ___L__2413__eval_2El__472[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2411__eval_2El__472;
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];

static long ___L__2411__eval_2El__472[] = {
return _acc;
}

oop k_cdr = (oop)k_cdr;
## defn k_car
oop k_car(oop _param0) {
  oop _acc = nil;

static long ___L__2416__eval_2El__471[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  if (_acc == nil) goto ___L__2418__eval_2El__471;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) & getLong(_tmp1));
  if (_acc == nil) goto ___L__2420__eval_2El__471;
  _acc = __3Clong_3E;
  goto ___L__2421__eval_2El__471;

static long ___L__2420__eval_2El__471[] = {
  _acc = LONG(-1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp1)];

static long ___L__2421__eval_2El__471[] = {
  goto ___L__2419__eval_2El__471;

static long ___L__2418__eval_2El__471[] = {
  _acc = __3Cundefined_3E;

static long ___L__2419__eval_2El__471[] = {
  _tmp0 = _acc;
  _acc = __3Cpair_3E;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2417__eval_2El__471;
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp0)];

static long ___L__2417__eval_2El__471[] = {
return _acc;
}

oop k_car = (oop)k_car;
## defn is_global
oop is_global(oop _param0) {
  oop _acc = nil;

static long ___L__2422__eval_2El__466[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _acc = LONG(2);
  _tmp1 = _acc;
  _acc = __3Cvariable_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp0 = _acc;

static long ___L__2423__eval_2El__467[] = {
  _acc = _tmp0;
  if (_acc == nil) goto ___L__2424__eval_2El__467;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = __3Cenv_3E;
  _tmp2 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Clong_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = (_acc == _tmp1) ? LONG(1) : LONG(0);

static long ___L__2424__eval_2El__467[] = {
return _acc;
}

oop is_global = (oop)is_global;
## defn new-<context>
oop new-<context>(oop _param0, oop _param1, oop _param2) {
  oop _acc = nil;

static long ___L__2425__eval_2El__456[] = {
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__2426__eval_2El__457[] = {
  _acc = _tmp1;
  if (_acc == nil) goto ___L__2429__eval_2El__457;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(3);
  _tmp2 = _acc;
  _acc = __3Ccontext_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp0 = _acc;

static long ___L__2429__eval_2El__457[] = {
  if (_acc == nil) goto ___L__2427__eval_2El__457;

static long ___L__2430__eval_2El__458[] = {

static long ___L__2431__eval_2El__459[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = __3Ccontext_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp4)] = _tmp2;

static long ___L__2432__eval_2El__460[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = _tmp2;
  _tmp2 = _acc;
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Ccontext_3E;
  _tmp5 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp4)] = _tmp2;
  goto ___L__2428__eval_2El__457;

static long ___L__2427__eval_2El__457[] = {

static long ___L__2433__eval_2El__461[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = _new_2Dbase_2D_3Ccontext_3E;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _tmp2 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _tmp0 = _acc;

static long ___L__2434__eval_2El__462[] = {
  _acc = _tmp1;
  if (_acc == nil) goto ___L__2435__eval_2El__462;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(3);
  _tmp1 = _acc;
  _acc = __3Ccontext_3E;
  _tmp3 = _acc;
  _acc = _tmp4;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp1)] = _tmp2;

static long ___L__2435__eval_2El__462[] = {

static long ___L__2428__eval_2El__457[] = {
  _acc = _tmp0;
return _acc;
}

oop new-<context> = (oop)new-<context>;
## defn new-base-<context>
oop new-base-<context>(oop _param0, oop _param1, oop _param2) {
  oop _acc = nil;

static long ___L__2436__eval_2El__440[] = {
  _acc = __3Ccontext_3E;
  _tmp0 = _acc;
  _acc = LONG(20);
  _tmp1 = _acc;
  _acc = _new_2Doops;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__2437__eval_2El__441[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2438__eval_2El__442[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Ccontext_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2439__eval_2El__443[] = {
  _acc = _tmp2;
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Ccontext_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2440__eval_2El__444[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _new_2D_3Carray_3E;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = __3Ccontext_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;
  _acc = _tmp1;
  _tmp0 = _acc;

static long ___L__2441__eval_2El__441[] = {
  _acc = (oop)&_tmp1;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
return _acc;
}

oop new-base-<context> = (oop)new-base-<context>;
## defn new-<env>
oop new-<env>(oop _param0, oop _param1, oop _param2) {
  oop _acc = nil;

static long ___L__2442__eval_2El__431[] = {
  _acc = __3Cenv_3E;
  _tmp0 = _acc;
  _acc = LONG(20);
  _tmp1 = _acc;
  _acc = _new_2Doops;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__2443__eval_2El__432[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2444__eval_2El__433[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cenv_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2445__eval_2El__434[] = {
  _acc = _tmp0;
  if (_acc == nil) goto ___L__2446__eval_2El__434;
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cenv_3E;
  _tmp3 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp2 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);
  _tmp4 = _acc;
  _acc = __3Clong_3E;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _acc = LONG(getLong(_acc) + getLong(_tmp0));
  goto ___L__2447__eval_2El__434;

static long ___L__2446__eval_2El__434[] = {
  _acc = LONG(0);

static long ___L__2447__eval_2El__434[] = {
  _tmp0 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cenv_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2448__eval_2El__435[] = {
  _acc = _tmp2;
  _tmp0 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = __3Cenv_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2449__eval_2El__436[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = _new_2D_3Carray_3E;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(3);
  _tmp2 = _acc;
  _acc = __3Cenv_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;
  _acc = _tmp1;
  _tmp0 = _acc;

static long ___L__2450__eval_2El__432[] = {
  _acc = (oop)&_tmp1;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
return _acc;
}

oop new-<env> = (oop)new-<env>;
## defn set_tail
/* form set_tail */
## defn set_head
/* form set_head */
## defn get_tail
/* form get_tail */
## defn get_head
/* form get_head */
## defn get_long
/* form get_long */
## defn is_long
/* form is_long */
## defn put
/* form put */
## defn get
/* form get */
## defn type_check_fail
oop type_check_fail(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2451__eval_2El__410[] = {

static long ___L__2452__eval_2El__410[] = {
  "illegal type: expected %d got %d"
,
    _acc = (oop)___L__2452__eval_2El__410;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _tmp1;
  _tmp2 = _acc;
  _acc = _fatal2;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _tmp2 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
return _acc;
}

oop type_check_fail = (oop)type_check_fail;
## defn is
/* form is */
## defn get-type
/* form get-type */
## defn new-<variable>
oop new-<variable>(oop _param0, oop _param1, oop _param2, oop _param3) {
  oop _acc = nil;

static long ___L__2453__eval_2El__387[] = {
  _acc = __3Cvariable_3E;
  _tmp0 = _acc;
  _acc = LONG(20);
  _tmp1 = _acc;
  _acc = _new_2Doops;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__2454__eval_2El__388[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2455__eval_2El__389[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2456__eval_2El__390[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2457__eval_2El__391[] = {
  _acc = _tmp2;
  _tmp0 = _acc;
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2458__eval_2El__392[] = {
  _acc = _tmp3;
  _tmp0 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(3);
  _tmp2 = _acc;
  _acc = __3Cvariable_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;
  _acc = _tmp1;
  _tmp0 = _acc;

static long ___L__2459__eval_2El__388[] = {
  _acc = (oop)&_tmp1;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
return _acc;
}

oop new-<variable> = (oop)new-<variable>;
## defn new-<subr>
oop new-<subr>(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2460__eval_2El__380[] = {
  _acc = __3Csubr_3E;
  _tmp0 = _acc;
  _acc = LONG(16);
  _tmp1 = _acc;
  _acc = _new_2Dbits;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__2461__eval_2El__381[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2462__eval_2El__382[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Csubr_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2463__eval_2El__383[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Csubr_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;
  _acc = _tmp1;
  _tmp0 = _acc;

static long ___L__2464__eval_2El__381[] = {
  _acc = (oop)&_tmp1;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
return _acc;
}

oop new-<subr> = (oop)new-<subr>;
## defn new-<fixed>
oop new-<fixed>(oop _param0) {
  oop _acc = nil;

static long ___L__2465__eval_2El__374[] = {
  _acc = __3Cfixed_3E;
  _tmp0 = _acc;
  _acc = LONG(4);
  _tmp1 = _acc;
  _acc = _new_2Doops;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__2466__eval_2El__375[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2467__eval_2El__376[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cfixed_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;
  _acc = _tmp1;
  _tmp0 = _acc;

static long ___L__2468__eval_2El__375[] = {
  _acc = (oop)&_tmp1;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
return _acc;
}

oop new-<fixed> = (oop)new-<fixed>;
## defn new-<form>
oop new-<form>(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2469__eval_2El__367[] = {
  _acc = __3Cform_3E;
  _tmp0 = _acc;
  _acc = LONG(8);
  _tmp1 = _acc;
  _acc = _new_2Doops;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__2470__eval_2El__368[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2471__eval_2El__369[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cform_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2472__eval_2El__370[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cform_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;
  _acc = _tmp1;
  _tmp0 = _acc;

static long ___L__2473__eval_2El__368[] = {
  _acc = (oop)&_tmp1;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
return _acc;
}

oop new-<form> = (oop)new-<form>;
## defn new-<expr>
oop new-<expr>(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2474__eval_2El__361[] = {
  _acc = __3Cexpr_3E;
  _tmp0 = _acc;
  _acc = LONG(16);
  _tmp1 = _acc;
  _acc = _new_2Doops;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__2475__eval_2El__362[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cexpr_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2476__eval_2El__363[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = __3Cexpr_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;
  _acc = _tmp1;
return _acc;
}

oop new-<expr> = (oop)new-<expr>;
## defn new-<array>
oop new-<array>(oop _param0) {
  oop _acc = nil;

static long ___L__2477__eval_2El__353[] = {
  _acc = _tmp0;
  if (_acc == nil) goto ___L__2478__eval_2El__353;
  _acc = _tmp0;
  goto ___L__2479__eval_2El__353;

static long ___L__2478__eval_2El__353[] = {
  _acc = LONG(1);

static long ___L__2479__eval_2El__353[] = {
  _tmp0 = _acc;

static long ___L__2480__eval_2El__354[] = {
  _acc = __3Carray_3E;
  _tmp1 = _acc;
  _acc = LONG(8);
  _tmp2 = _acc;
  _acc = _new_2Doops;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp2 = _acc;

static long ___L__2481__eval_2El__355[] = {
  _acc = (oop)&_tmp2;
  _tmp1 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2482__eval_2El__356[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Carray_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp3)] = _tmp1;

static long ___L__2483__eval_2El__357[] = {
  _acc = __3C__array_3E;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(4);
  _acc = LONG(getLong(_acc) * getLong(_tmp3));
  _tmp3 = _acc;
  _acc = _new_2Doops;
  _tmp0 = _tmp1;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp3 = _acc;
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = __3Carray_3E;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp1)] = _tmp3;
  _acc = _tmp2;
  _tmp3 = _acc;

static long ___L__2484__eval_2El__355[] = {
  _acc = (oop)&_tmp2;
  _tmp1 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp3;
return _acc;
}

oop new-<array> = (oop)new-<array>;
## defn new-<pair>
oop new-<pair>(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2485__eval_2El__347[] = {
  _acc = __3Cpair_3E;
  _tmp0 = _acc;
  _acc = LONG(12);
  _tmp1 = _acc;
  _acc = _new_2Doops;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__2486__eval_2El__348[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cpair_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2487__eval_2El__349[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cpair_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;
  _acc = _tmp1;
return _acc;
}

oop new-<pair> = (oop)new-<pair>;
## defn new-<symbol>
oop new-<symbol>(oop _param0) {
  oop _acc = nil;

static long ___L__2488__eval_2El__342[] = {
  _acc = __3Csymbol_3E;
  _tmp0 = _acc;
  _acc = LONG(4);
  _tmp1 = _acc;
  _acc = _new_2Dbits;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__2489__eval_2El__343[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _strdup_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Csymbol_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;
  _acc = _tmp1;
return _acc;
}

oop new-<symbol> = (oop)new-<symbol>;
## defn new-<string>
oop new-<string>(oop _param0) {
  oop _acc = nil;

static long ___L__2490__eval_2El__336[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _strlen_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__2491__eval_2El__337[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = ___new_2D_3Cstring_3E;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__2492__eval_2El__338[] = {
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cstring_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = _memcpy_24stub;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);
  _acc = _tmp1;
return _acc;
}

oop new-<string> = (oop)new-<string>;
## defn _new-<string>
oop _new-<string>(oop _param0) {
  oop _acc = nil;

static long ___L__2493__eval_2El__329[] = {
  _acc = __3Cstring_3E;
  _tmp0 = _acc;
  _acc = LONG(8);
  _tmp1 = _acc;
  _acc = _new_2Doops;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__2494__eval_2El__330[] = {
  _acc = (oop)&_tmp1;
  _tmp0 = _acc;
  _acc = _gc__push__root;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2495__eval_2El__331[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _new_2D_3Clong_3E;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cstring_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;

static long ___L__2496__eval_2El__332[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) + getLong(_tmp0));
  _tmp0 = _acc;
  _acc = _gc__malloc__atomic;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cstring_3E;
  _tmp4 = _acc;
  _acc = _tmp1;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;
  _acc = _tmp1;
  _tmp0 = _acc;

static long ___L__2497__eval_2El__330[] = {
  _acc = (oop)&_tmp1;
  _tmp2 = _acc;
  _acc = _gc__pop__root;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
return _acc;
}

oop _new-<string> = (oop)_new-<string>;
## defn new-<long>
oop new-<long>(oop _param0) {
  oop _acc = nil;

static long ___L__2498__eval_2El__324[] = {
  _acc = __3Clong_3E;
  _tmp0 = _acc;
  _acc = LONG(4);
  _tmp1 = _acc;
  _acc = _new_2Dbits;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;

static long ___L__2499__eval_2El__325[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Clong_3E;
  _tmp3 = _acc;
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp0;
  _acc = _tmp1;
return _acc;
}

oop new-<long> = (oop)new-<long>;
## defn new-oops
oop new-oops(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2500__eval_2El__317[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _gc__malloc;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__2501__eval_2El__318[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp0;
  ((oop*)_acc)[getLong(_tmp2)] = _tmp1;
  _acc = _tmp0;
return _acc;
}

oop new-oops = (oop)new-oops;
## defn new-bits
oop new-bits(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2502__eval_2El__312[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _gc__malloc__atomic;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__2503__eval_2El__313[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(-1);
  _tmp2 = _acc;
  _acc = _tmp0;
  ((oop*)_acc)[getLong(_tmp2)] = _tmp1;
  _acc = _tmp0;
return _acc;
}

oop new-bits = (oop)new-bits;
## defn opt_optimised
oop opt_optimised = LONG(0);

## defn opt_verbose
oop opt_verbose = LONG(0);

## defn f_define
oop f_define = LONG(0);

## defn f_let
oop f_let = LONG(0);

## defn f_lambda
oop f_lambda = LONG(0);

## defn f_quote
oop f_quote = LONG(0);

## defn f_set
oop f_set = LONG(0);

## defn s_applicators
oop s_applicators = LONG(0);

## defn s_evaluators
oop s_evaluators = LONG(0);

## defn s_encoders
oop s_encoders = LONG(0);

## defn s_expanders
oop s_expanders = LONG(0);

## defn s_unquote_splicing
oop s_unquote_splicing = LONG(0);

## defn s_unquote
oop s_unquote = LONG(0);

## defn s_quasiquote
oop s_quasiquote = LONG(0);

## defn s_quote
oop s_quote = LONG(0);

## defn s_let
oop s_let = LONG(0);

## defn s_lambda
oop s_lambda = LONG(0);

## defn s_set
oop s_set = LONG(0);

## defn s_define
oop s_define = LONG(0);

## defn s_dot
oop s_dot = LONG(0);

## defn s_t
oop s_t = LONG(0);

## defn applicators
oop applicators = LONG(0);

## defn evaluators
oop evaluators = LONG(0);

## defn encoders
oop encoders = LONG(0);

## defn expanders
oop expanders = LONG(0);

## defn globals
oop globals = LONG(0);

## defn symbols
oop symbols = LONG(0);

## defn <context>
oop <context> = LONG(15);

## defn <env>
oop <env> = LONG(14);

## defn <variable>
oop <variable> = LONG(13);

## defn <subr>
oop <subr> = LONG(12);

## defn <fixed>
oop <fixed> = LONG(11);

## defn <form>
oop <form> = LONG(10);

## defn <expr>
oop <expr> = LONG(9);

## defn <array>
oop <array> = LONG(8);

## defn <_array>
oop <_array> = LONG(7);

## defn <pair>
oop <pair> = LONG(6);

## defn <symbol>
oop <symbol> = LONG(5);

## defn <string>
oop <string> = LONG(4);

## defn <double>
oop <double> = LONG(3);

## defn <long>
oop <long> = LONG(2);

## defn <data>
oop <data> = LONG(1);

## defn <undefined>
oop <undefined> = LONG(0);

## defn DONE
oop DONE = LONG(-4);

## defn EOF
oop EOF = LONG(-1);

## defn fscanf
extern oop fscanf();
oop fscanf$stub = (oop)&fscanf;

## defn fflush
extern oop fflush();
oop fflush$stub = (oop)&fflush;

## defn fclose
extern oop fclose();
oop fclose$stub = (oop)&fclose;

## defn fdopen
extern oop fdopen();
oop fdopen$stub = (oop)&fdopen;

## defn fopen
extern oop fopen();
oop fopen$stub = (oop)&fopen;

## defn ungetc
extern oop ungetc();
oop ungetc$stub = (oop)&ungetc;

## defn getc
extern oop getc();
oop getc$stub = (oop)&getc;

## defn putc
extern oop putc();
oop putc$stub = (oop)&putc;

## defn strtoul
extern oop strtoul();
oop strtoul$stub = (oop)&strtoul;

## defn strdup
extern oop strdup();
oop strdup$stub = (oop)&strdup;

## defn strcmp
extern oop strcmp();
oop strcmp$stub = (oop)&strcmp;

## defn strlen
extern oop strlen();
oop strlen$stub = (oop)&strlen;

## defn gc_malloc_atomic
oop gc_malloc_atomic(oop _param0) {
  oop _acc = nil;

static long ___L__2504__eval_2El__243[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _gc__malloc;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__2505__eval_2El__244[] = {
  _acc = LONG(3);
  _tmp1 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cheader_3E;
  _tmp3 = _acc;
  _acc = LONG(16);
  _tmp4 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) - getLong(_tmp4));
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp1;
  _acc = _tmp0;
return _acc;
}

oop gc_malloc_atomic = (oop)gc_malloc_atomic;
## defn gc_malloc
oop gc_malloc(oop _param0) {
  oop _acc = nil;

static long ___L__2506__eval_2El__203[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(3);
  _acc = LONG(getLong(_acc) + getLong(_tmp0));
  _tmp0 = _acc;
  _acc = LONG(-4);
  _acc = LONG(getLong(_acc) & getLong(_tmp0));
  _tmp0 = _acc;

static long ___L__2507__eval_2El__204[] = {
  _acc = _gc__frequency;
  _tmp0 = _acc;
  _acc = _gc__alloc__count;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2508__eval_2El__204;
  _acc = _gc__gcollect;
  _acc = ((oop (*)())_acc)();

static long ___L__2508__eval_2El__204[] = {

static long ___L__2509__eval_2El__205[] = {
  _acc = LONG(2);
  _tmp0 = _acc;
  _acc = __3Cheader_3E;
  _tmp1 = _acc;
  _acc = _gc__memory__last;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;

static long ___L__2510__eval_2El__207[] = {
  _acc = LONG(16);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) + getLong(_tmp1));
  _tmp1 = _acc;

static long ___L__2511__eval_2El__208[] = {
  goto ___L__2513__eval_2El__208;

static long ___L__2512__eval_2El__208[] = {

static long ___L__2514__eval_2El__209[] = {
  goto ___L__2516__eval_2El__209;

static long ___L__2515__eval_2El__209[] = {

static long ___L__2516__eval_2El__209[] = {

static long ___L__2517__eval_2El__210[] = {
  _acc = LONG(0);

static long ___L__2518__eval_2El__212[] = {
  _acc = LONG(1);
  _tmp3 = _acc;
  _acc = __3Cheader_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp3 = _acc;
  _acc = LONG(0);
  _acc = (_acc == _tmp3) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2519__eval_2El__212;

static long ___L__2521__eval_2El__213[] = {
  _acc = LONG(0);
  _tmp3 = _acc;
  _acc = __3Cheader_3E;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp3 = _acc;

static long ___L__2522__eval_2El__214[] = {
  goto ___L__2524__eval_2El__214;

static long ___L__2523__eval_2El__214[] = {

static long ___L__2525__eval_2El__216[] = {
  _acc = LONG(2);
  _tmp4 = _acc;
  _acc = __3Cheader_3E;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp4 = _acc;

static long ___L__2526__eval_2El__217[] = {
  _acc = LONG(2);
  _tmp6 = _acc;
  _acc = __3Cheader_3E;
  _tmp5 = _acc;
  _acc = _tmp4;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp6 = _acc;
  _acc = LONG(2);
  _tmp7 = _acc;
  _acc = __3Cheader_3E;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp7)] = _tmp6;

static long ___L__2527__eval_2El__218[] = {
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Cheader_3E;
  _tmp7 = _acc;
  _acc = _tmp4;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp6 = _acc;
  _acc = LONG(16);
  _acc = LONG(getLong(_acc) + getLong(_tmp6));
  _tmp6 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) + getLong(_tmp6));
  _tmp6 = _acc;
  _acc = LONG(0);
  _tmp8 = _acc;
  _acc = __3Cheader_3E;
  _tmp7 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp8)] = _tmp6;
  _tmp3 = _acc;

static long ___L__2528__eval_2El__219[] = {
  _acc = _gc__memory__last;
  _tmp6 = _acc;
  _acc = _tmp4;
  _acc = (_acc == _tmp6) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2529__eval_2El__219;
  _acc = _tmp2;
  _gc__memory__last = _acc;

static long ___L__2529__eval_2El__219[] = {

static long ___L__2524__eval_2El__214[] = {

static long ___L__2530__eval_2El__214[] = {
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cheader_3E;
  _tmp6 = _acc;
  _acc = LONG(2);
  _tmp8 = _acc;
  _acc = __3Cheader_3E;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp8)];
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp4 = _acc;
  _acc = LONG(0);
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2531__eval_2El__214;

static long ___L__2532__eval_2El__215[] = {
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = LONG(16);
  _acc = LONG(getLong(_acc) + getLong(_tmp4));
  _tmp4 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) + getLong(_tmp4));
  _tmp4 = _acc;
  _acc = LONG(2);
  _tmp8 = _acc;
  _acc = __3Cheader_3E;
  _tmp6 = _acc;
  _acc = _tmp2;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp8)];
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);

static long ___L__2531__eval_2El__214[] = {
  if (_acc != nil) goto ___L__2523__eval_2El__214;

static long ___L__2533__eval_2El__220[] = {
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = _tmp1;
  _acc = (getLong(_acc) < getLong(_tmp4)) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2536__eval_2El__220;
  _acc = _tmp3;
  _tmp4 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);

static long ___L__2536__eval_2El__220[] = {
  if (_acc == nil) goto ___L__2534__eval_2El__220;

static long ___L__2537__eval_2El__221[] = {
  _acc = LONG(0);

static long ___L__2538__eval_2El__223[] = {
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _tmp3;
  _acc = (getLong(_acc) > getLong(_tmp4)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2539__eval_2El__223;

static long ___L__2540__eval_2El__224[] = {
  _acc = _tmp1;
  _tmp4 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) + getLong(_tmp4));
  _tmp4 = _acc;
  _acc = LONG(0);

static long ___L__2541__eval_2El__226[] = {
  _acc = LONG(16);
  _tmp8 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) + getLong(_tmp8));
  _tmp8 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) - getLong(_tmp8));
  _tmp8 = _acc;
  _acc = LONG(0);
  _tmp7 = _acc;
  _acc = __3Cheader_3E;
  _tmp6 = _acc;
  _acc = _tmp4;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp7)] = _tmp8;

static long ___L__2542__eval_2El__227[] = {
  _acc = LONG(0);
  _tmp8 = _acc;
  _acc = LONG(1);
  _tmp7 = _acc;
  _acc = __3Cheader_3E;
  _tmp5 = _acc;
  _acc = _tmp4;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp7)] = _tmp8;

static long ___L__2543__eval_2El__228[] = {
  _acc = LONG(2);
  _tmp8 = _acc;
  _acc = __3Cheader_3E;
  _tmp7 = _acc;
  _acc = _tmp2;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp8)];
  _tmp8 = _acc;
  _acc = LONG(2);
  _tmp6 = _acc;
  _acc = __3Cheader_3E;
  _tmp7 = _acc;
  _acc = _tmp4;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp6)] = _tmp8;

static long ___L__2544__eval_2El__229[] = {
  _acc = _tmp0;
  _tmp8 = _acc;
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Cheader_3E;
  _tmp5 = _acc;
  _acc = _tmp2;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp6)] = _tmp8;

static long ___L__2545__eval_2El__230[] = {
  _acc = _tmp4;
  _tmp8 = _acc;
  _acc = LONG(2);
  _tmp6 = _acc;
  _acc = __3Cheader_3E;
  _tmp7 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp6)] = _tmp8;

static long ___L__2546__eval_2El__231[] = {
  _acc = _tmp0;
  _tmp3 = _acc;

static long ___L__2539__eval_2El__223[] = {

static long ___L__2547__eval_2El__232[] = {
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = LONG(1);
  _tmp8 = _acc;
  _acc = __3Cheader_3E;
  _tmp6 = _acc;
  _acc = _tmp2;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp8)] = _tmp4;

static long ___L__2548__eval_2El__233[] = {
  _acc = _tmp2;
  _gc__memory__last = _acc;
  _acc = LONG(0);

static long ___L__2549__eval_2El__235[] = {
  _acc = LONG(16);
  _tmp4 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) + getLong(_tmp4));
  _tmp4 = _acc;

static long ___L__2550__eval_2El__236[] = {
  _acc = _tmp4;
  _tmp8 = _acc;
  _acc = LONG(0);
  _tmp5 = _acc;
  _acc = _tmp3;
  _tmp6 = _acc;
  _acc = _memset_24stub;
  _tmp0 = _tmp8;
  _tmp1 = _tmp5;
  _tmp2 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__2551__eval_2El__237[] = {
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _gc__alloc__count;
  _acc = LONG(getLong(_acc) + getLong(_tmp6));
  _gc__alloc__count = _acc;

static long ___L__2552__eval_2El__238[] = {
  _acc = _tmp4;
  goto ___L__2553__eval_2El__238;
  goto ___L__2535__eval_2El__220;

static long ___L__2534__eval_2El__220[] = {

static long ___L__2535__eval_2El__220[] = {
  goto ___L__2520__eval_2El__212;

static long ___L__2519__eval_2El__212[] = {

static long ___L__2520__eval_2El__212[] = {

static long ___L__2554__eval_2El__239[] = {
  _acc = LONG(2);
  _tmp3 = _acc;
  _acc = __3Cheader_3E;
  _tmp4 = _acc;
  _acc = _tmp2;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp3)];
  _tmp2 = _acc;
  _tmp3 = _acc;
  _acc = _tmp0;
  _acc = (_acc != _tmp3) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2515__eval_2El__209;

static long ___L__2555__eval_2El__240[] = {
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = LONG(16);
  _acc = LONG(getLong(_acc) + getLong(_tmp3));
  _tmp3 = _acc;
  _acc = _gc__quantum;
  _tmp6 = _acc;
  _acc = _max;
  _tmp0 = _tmp3;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp6 = _acc;
  _acc = _gc__grow__memory;
  _tmp0 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2513__eval_2El__208[] = {
  _acc = LONG(1);
  if (_acc != nil) goto ___L__2512__eval_2El__208;
___L__2553__eval_2El__238:
  return _acc;
}

oop gc_malloc = (oop)gc_malloc;
## defn gc_gcollect
oop gc_gcollect() {
  oop _acc = nil;
  _acc = LONG(0);

static long ___L__2556__eval_2El__194[] = {
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__2557__eval_2El__195[] = {
  goto ___L__2559__eval_2El__195;

static long ___L__2558__eval_2El__195[] = {
  _acc = LONG(0);

static long ___L__2560__eval_2El__197[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _gc__roots;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = _gc__mark__and__trace;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2561__eval_2El__198[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(1);
  _acc = LONG(getLong(_acc) + getLong(_tmp1));
  _tmp0 = _acc;

static long ___L__2559__eval_2El__195[] = {

static long ___L__2562__eval_2El__195[] = {
  _acc = _gc__root__count;
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) < getLong(_tmp1)) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2558__eval_2El__195;

static long ___L__2563__eval_2El__199[] = {
  _acc = _gc__sweep;
  _acc = ((oop (*)())_acc)();

static long ___L__2564__eval_2El__200[] = {
  _acc = LONG(0);
  _gc__alloc__count = _acc;
return _acc;
}

oop gc_gcollect = (oop)gc_gcollect;
## defn gc_mark_and_trace
oop gc_mark_and_trace(oop _param0) {
  oop _acc = nil;

static long ___L__2565__eval_2El__173[] = {
  _acc = _tmp0;
  if (_acc == nil) goto ___L__2566__eval_2El__173;

static long ___L__2567__eval_2El__174[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = LONG(1);
  _acc = LONG(getLong(_acc) & getLong(_tmp0));
  _acc = (_acc == nil) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2566__eval_2El__173;

static long ___L__2568__eval_2El__175[] = {
  _acc = LONG(16);
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) - getLong(_tmp0));
  _tmp0 = _acc;

static long ___L__2569__eval_2El__176[] = {
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = __3Cheader_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = LONG(0);

static long ___L__2570__eval_2El__179[] = {
  _acc = LONG(4);
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc != nil) goto ___L__2571__eval_2El__179;

static long ___L__2572__eval_2El__180[] = {

static long ___L__2573__eval_2El__181[] = {
  _acc = LONG(4);
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) | getLong(_tmp3));
  _tmp3 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cheader_3E;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp3;

static long ___L__2574__eval_2El__182[] = {
  _acc = LONG(2);
  _tmp3 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) & getLong(_tmp3));
  if (_acc != nil) goto ___L__2575__eval_2El__182;

static long ___L__2576__eval_2El__183[] = {
  _acc = LONG(2);
  _tmp3 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cheader_3E;
  _tmp5 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _acc = LONG(getLong(_acc) >> getLong(_tmp3));
  _tmp3 = _acc;
  _acc = LONG(0);

static long ___L__2577__eval_2El__185[] = {
  goto ___L__2579__eval_2El__185;

static long ___L__2578__eval_2El__185[] = {

static long ___L__2580__eval_2El__186[] = {
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) - getLong(_tmp2));
  _tmp3 = _acc;
  _acc = LONG(0);

static long ___L__2581__eval_2El__188[] = {
  _acc = _tmp3;
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = ((oop*)_acc)[getLong(_tmp2)];
  _tmp2 = _acc;
  _acc = _gc__mark__and__trace;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2579__eval_2El__185[] = {
  _acc = _tmp3;
  if (_acc != nil) goto ___L__2578__eval_2El__185;

static long ___L__2575__eval_2El__182[] = {

static long ___L__2571__eval_2El__179[] = {

static long ___L__2566__eval_2El__173[] = {
return _acc;
}

oop gc_mark_and_trace = (oop)gc_mark_and_trace;
## defn gc_sweep
oop gc_sweep() {
  oop _acc = nil;
  _acc = LONG(0);

static long ___L__2582__eval_2El__149[] = {
  _acc = _gc__memory__base;
  _tmp0 = _acc;
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = LONG(0);
  _tmp3 = _acc;

static long ___L__2583__eval_2El__153[] = {
  goto ___L__2585__eval_2El__153;

static long ___L__2584__eval_2El__153[] = {
  _acc = LONG(0);

static long ___L__2586__eval_2El__155[] = {
  _acc = LONG(1);
  _tmp4 = _acc;
  _acc = __3Cheader_3E;
  _tmp5 = _acc;
  _acc = _tmp0;
  _tmp6 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp6;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp4 = _acc;

static long ___L__2587__eval_2El__156[] = {
  _acc = LONG(4);
  _tmp6 = _acc;
  _acc = _tmp4;
  _acc = LONG(getLong(_acc) & getLong(_tmp6));
  if (_acc == nil) goto ___L__2588__eval_2El__156;

static long ___L__2590__eval_2El__157[] = {

static long ___L__2591__eval_2El__158[] = {
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Cheader_3E;
  _tmp5 = _acc;
  _acc = _tmp0;
  _tmp7 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp7;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp6 = _acc;
  _acc = _tmp2;
  _acc = LONG(getLong(_acc) + getLong(_tmp6));
  _tmp2 = _acc;

static long ___L__2592__eval_2El__159[] = {
  _acc = LONG(1);
  _tmp6 = _acc;
  _acc = _tmp1;
  _acc = LONG(getLong(_acc) + getLong(_tmp6));
  _tmp1 = _acc;

static long ___L__2593__eval_2El__160[] = {
  _acc = LONG(4);
  _tmp6 = _acc;
  _acc = _tmp4;
  _acc = LONG(getLong(_acc) ^ getLong(_tmp6));
  _tmp6 = _acc;
  _acc = LONG(1);
  _tmp7 = _acc;
  _acc = __3Cheader_3E;
  _tmp5 = _acc;
  _acc = _tmp0;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp5;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp7)] = _tmp6;
  goto ___L__2589__eval_2El__156;

static long ___L__2588__eval_2El__156[] = {
  _acc = LONG(0);

static long ___L__2594__eval_2El__162[] = {
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = __3Cheader_3E;
  _tmp7 = _acc;
  _acc = _tmp0;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp6)];
  _tmp6 = _acc;
  _acc = _tmp3;
  _acc = LONG(getLong(_acc) + getLong(_tmp6));
  _tmp3 = _acc;

static long ___L__2595__eval_2El__163[] = {
  _acc = LONG(0);
  _tmp6 = _acc;
  _acc = LONG(1);
  _tmp8 = _acc;
  _acc = __3Cheader_3E;
  _tmp7 = _acc;
  _acc = _tmp0;
  _tmp5 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp7;
  _tmp1 = _tmp5;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp8)] = _tmp6;

static long ___L__2589__eval_2El__156[] = {

static long ___L__2596__eval_2El__164[] = {
  _acc = LONG(2);
  _tmp4 = _acc;
  _acc = __3Cheader_3E;
  _tmp6 = _acc;
  _acc = _tmp0;
  _tmp8 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp6;
  _tmp1 = _tmp8;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp4)];
  _tmp0 = _acc;
  _tmp4 = _acc;
  _acc = _gc__memory__base;
  _acc = (_acc == _tmp4) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2597__eval_2El__164;

static long ___L__2598__eval_2El__165[] = {
  _acc = LONG(0);
  _tmp0 = _acc;

static long ___L__2597__eval_2El__164[] = {

static long ___L__2585__eval_2El__153[] = {
  _acc = _tmp0;
  if (_acc != nil) goto ___L__2584__eval_2El__153;

static long ___L__2599__eval_2El__166[] = {
  _acc = _tmp1;
  _gc__objects__live = _acc;

static long ___L__2600__eval_2El__167[] = {
  _acc = _tmp2;
  _gc__bytes__used = _acc;

static long ___L__2601__eval_2El__168[] = {
  _acc = _tmp3;
  _gc__bytes__free = _acc;
  _acc = LONG(0);
return _acc;
}

oop gc_sweep = (oop)gc_sweep;
## defn gc_size
oop gc_size(oop _param0) {
  oop _acc = nil;

static long ___L__2602__eval_2El__145[] = {
  _acc = LONG(0);
  _tmp0 = _acc;
  _acc = __3Cheader_3E;
  _tmp1 = _acc;
  _acc = LONG(16);
  _tmp2 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) - getLong(_tmp2));
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp0)];
return _acc;
}

oop gc_size = (oop)gc_size;
## defn gc_grow_memory
oop gc_grow_memory(oop _param0) {
  oop _acc = nil;

static long ___L__2603__eval_2El__141[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _new__memory__block;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__2604__eval_2El__142[] = {
  _acc = LONG(2);
  _tmp1 = _acc;
  _acc = __3Cheader_3E;
  _tmp2 = _acc;
  _acc = _gc__memory__last;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = ((oop*)_acc)[getLong(_tmp1)];
  _tmp1 = _acc;
  _acc = LONG(2);
  _tmp3 = _acc;
  _acc = __3Cheader_3E;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp2;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp3)] = _tmp1;

static long ___L__2605__eval_2El__143[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(2);
  _tmp3 = _acc;
  _acc = __3Cheader_3E;
  _tmp4 = _acc;
  _acc = _gc__memory__last;
  _tmp2 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp3)] = _tmp1;
return _acc;
}

oop gc_grow_memory = (oop)gc_grow_memory;
## defn gc_pop_root
oop gc_pop_root(oop _param0) {
  oop _acc = nil;

static long ___L__2606__eval_2El__135[] = {
  _acc = _gc__root__count;
  if (_acc != nil) goto ___L__2607__eval_2El__135;

static long ___L__2608__eval_2El__135[] = {
  "root table underflow"
,
    _acc = (oop)___L__2608__eval_2El__135;
  _tmp0 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2607__eval_2El__135[] = {

static long ___L__2609__eval_2El__136[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _gc__root__count;
  _acc = LONG(getLong(_acc) - getLong(_tmp0));
  _gc__root__count = _acc;
  _acc = LONG(0);

static long ___L__2610__eval_2El__138[] = {
  _acc = _gc__root__count;
  _tmp0 = _acc;
  _acc = _gc__roots;
  _acc = ((oop*)_acc)[getLong(_tmp0)];
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2611__eval_2El__138;

static long ___L__2612__eval_2El__138[] = {
  "non-lifo root"
,
    _acc = (oop)___L__2612__eval_2El__138;
  _tmp0 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2611__eval_2El__138[] = {
return _acc;
}

oop gc_pop_root = (oop)gc_pop_root;
## defn gc_push_root
oop gc_push_root(oop _param0) {
  oop _acc = nil;

static long ___L__2613__eval_2El__125[] = {
  _acc = _gc__root__max;
  _tmp0 = _acc;
  _acc = _gc__root__count;
  _acc = (_acc == _tmp0) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2614__eval_2El__125;

static long ___L__2615__eval_2El__126[] = {
  _acc = LONG(32);
  _tmp0 = _acc;
  _acc = _gc__root__max;
  _tmp1 = _acc;
  _acc = LONG(2);
  _acc = LONG(getLong(_acc) * getLong(_tmp1));
  _tmp1 = _acc;
  _acc = _max;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _gc__root__max = _acc;
  _tmp1 = _acc;
  _acc = LONG(4);
  _acc = LONG(getLong(_acc) * getLong(_tmp1));
  _tmp1 = _acc;
  _acc = _malloc_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp1 = _acc;

static long ___L__2616__eval_2El__127[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _gc__roots;
  _tmp2 = _acc;
  _acc = _gc__root__count;
  _tmp3 = _acc;
  _acc = LONG(4);
  _acc = LONG(getLong(_acc) * getLong(_tmp3));
  _tmp3 = _acc;
  _acc = _memcpy_24stub;
  _tmp0 = _tmp0;
  _tmp1 = _tmp2;
  _tmp2 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__2617__eval_2El__128[] = {
  _acc = _gc__roots;
  if (_acc == nil) goto ___L__2618__eval_2El__128;
  _acc = _gc__roots;
  _tmp3 = _acc;
  _acc = _free_24stub;
  _tmp0 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2618__eval_2El__128[] = {

static long ___L__2619__eval_2El__129[] = {
  _acc = _tmp1;
  _gc__roots = _acc;

static long ___L__2614__eval_2El__125[] = {

static long ___L__2620__eval_2El__130[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _gc__root__count;
  _tmp3 = _acc;
  _acc = _gc__roots;
  ((oop*)_acc)[getLong(_tmp3)] = _tmp1;
  _acc = LONG(0);

static long ___L__2621__eval_2El__132[] = {
  _acc = _gc__root__count;
  _tmp1 = _acc;
  _acc = LONG(1);
  _acc = LONG(getLong(_acc) + getLong(_tmp1));
  _gc__root__count = _acc;
return _acc;
}

oop gc_push_root = (oop)gc_push_root;
## defn gc_initialise
oop gc_initialise() {
  oop _acc = nil;

static long ___L__2622__eval_2El__120[] = {
  _acc = _gc__quantum;
  _tmp0 = _acc;
  _acc = _new__memory__block;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__2623__eval_2El__121[] = {
  _acc = _tmp0;
  _gc__memory__base = _acc;

static long ___L__2624__eval_2El__122[] = {
  _acc = _tmp0;
  _gc__memory__last = _acc;
return _acc;
}

oop gc_initialise = (oop)gc_initialise;
## defn new_memory_block
oop new_memory_block(oop _param0) {
  oop _acc = nil;

static long ___L__2625__eval_2El__111[] = {
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _malloc_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _tmp0 = _acc;

static long ___L__2626__eval_2El__112[] = {
  _acc = _tmp0;
  if (_acc != nil) goto ___L__2627__eval_2El__112;

static long ___L__2628__eval_2El__112[] = {
  "out of memory"
,
    _acc = (oop)___L__2628__eval_2El__112;
  _tmp1 = _acc;
  _acc = _fatal;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2627__eval_2El__112[] = {

static long ___L__2629__eval_2El__113[] = {
  _acc = LONG(16);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) - getLong(_tmp1));
  _tmp1 = _acc;
  _acc = LONG(0);
  _tmp2 = _acc;
  _acc = __3Cheader_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp1;

static long ___L__2630__eval_2El__114[] = {
  _acc = LONG(0);
  _tmp1 = _acc;
  _acc = LONG(1);
  _tmp2 = _acc;
  _acc = __3Cheader_3E;
  _tmp4 = _acc;
  _acc = _tmp0;
  _tmp3 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp4;
  _tmp1 = _tmp3;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp1;

static long ___L__2631__eval_2El__115[] = {
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = LONG(2);
  _tmp2 = _acc;
  _acc = __3Cheader_3E;
  _tmp3 = _acc;
  _acc = _tmp0;
  _tmp4 = _acc;
  _acc = __25typecheck;
  _tmp0 = _tmp3;
  _tmp1 = _tmp4;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  ((oop*)_acc)[getLong(_tmp2)] = _tmp1;
  _acc = LONG(0);
  _acc = _tmp0;
return _acc;
}

oop new_memory_block = (oop)new_memory_block;
## defn k_error
/* form k_error */
## defn fatal2
oop fatal2(oop _param0, oop _param1, oop _param2) {
  oop _acc = nil;

static long ___L__2632__eval_2El__101[] = {

static long ___L__2633__eval_2El__101[] = {
  "\012eval.k: "
,
    _acc = (oop)___L__2633__eval_2El__101;
  _tmp0 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _tmp2;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _tmp2 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1, _arg2);

static long ___L__2634__eval_2El__101[] = {
  "\012"
,
    _acc = (oop)___L__2634__eval_2El__101;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();
return _acc;
}

oop fatal2 = (oop)fatal2;
## defn fatal1
oop fatal1(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2635__eval_2El__100[] = {

static long ___L__2636__eval_2El__100[] = {
  "\012eval.k: "
,
    _acc = (oop)___L__2636__eval_2El__100;
  _tmp0 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _tmp0;
  _tmp0 = _acc;
  _acc = _tmp1;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2637__eval_2El__100[] = {
  "\012"
,
    _acc = (oop)___L__2637__eval_2El__100;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
  _acc = _die;
  _acc = ((oop (*)())_acc)();
return _acc;
}

oop fatal1 = (oop)fatal1;
## defn fatal
oop fatal(oop _param0) {
  oop _acc = nil;

static long ___L__2638__eval_2El__98[] = {

static long ___L__2639__eval_2El__98[] = {
  "\012eval.k: %s\012"
,
    _acc = (oop)___L__2639__eval_2El__98;
  _tmp0 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp0;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _exit_24stub;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop fatal = (oop)fatal;
## defn die
oop die() {
  oop _acc = nil;

static long ___L__2640__eval_2El__599[] = {
  _acc = _trace__depth;
  _tmp0 = _acc;

static long ___L__2641__eval_2El__600[] = {
  goto ___L__2643__eval_2El__600;

static long ___L__2642__eval_2El__600[] = {

static long ___L__2644__eval_2El__601[] = {

static long ___L__2645__eval_2El__601[] = {
  "%3d: "
,
    _acc = (oop)___L__2645__eval_2El__601;
  _tmp1 = _acc;
  _acc = _tmp0;
  _tmp2 = _acc;
  _acc = _printf_24stub;
  _tmp0 = _tmp1;
  _tmp1 = _tmp2;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);

static long ___L__2646__eval_2El__602[] = {
  _acc = _trace__stack;
  _tmp2 = _acc;
  _acc = _tmp0;
  _tmp1 = _acc;
  _acc = _k__array__at;
  _tmp0 = _tmp2;
  _tmp1 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0, _arg1);
  _tmp1 = _acc;
  _acc = _k__dumpln;
  _tmp0 = _tmp1;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2643__eval_2El__600[] = {

static long ___L__2647__eval_2El__600[] = {
  _acc = LONG(1);
  _tmp1 = _acc;
  _acc = _tmp0;
  _acc = LONG(getLong(_acc) - getLong(_tmp1));
  _tmp0 = _acc;
  _tmp1 = _acc;
  _acc = LONG(0);
  _acc = (getLong(_acc) <= getLong(_tmp1)) ? LONG(1) : LONG(0);
  if (_acc != nil) goto ___L__2642__eval_2El__600;

static long ___L__2648__eval_2El__603[] = {
  _acc = LONG(1);
  _tmp0 = _acc;
  _acc = _exit_24stub;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);
return _acc;
}

oop die = (oop)die;
## defn trace_depth
oop trace_depth = LONG(0);

## defn trace_stack
oop trace_stack = LONG(0);

## defn max
oop max(oop _param0, oop _param1) {
  oop _acc = nil;

static long ___L__2649__eval_2El__91[] = {
  _acc = _tmp1;
  _tmp0 = _acc;
  _acc = _tmp0;
  _acc = (getLong(_acc) > getLong(_tmp0)) ? LONG(1) : LONG(0);
  if (_acc == nil) goto ___L__2650__eval_2El__91;
  _acc = _tmp0;
  goto ___L__2651__eval_2El__91;

static long ___L__2650__eval_2El__91[] = {
  _acc = _tmp1;

static long ___L__2651__eval_2El__91[] = {
return _acc;
}

oop max = (oop)max;
## defn <header>-flags-used+atom
/* form <header>-flags-used+atom */
## defn <header>-flags-mark
/* form <header>-flags-mark */
## defn <header>-flags-atom
/* form <header>-flags-atom */
## defn <header>-flags-used
/* form <header>-flags-used */
## defn size-of-structure
/* form size-of-structure */
## defn gc_collection_count
oop gc_collection_count = LONG(0);

## defn gc_alloc_count
oop gc_alloc_count = LONG(0);

## defn gc_memory_last
oop gc_memory_last = LONG(0);

## defn gc_memory_base
oop gc_memory_base = LONG(0);

## defn gc_root_max
oop gc_root_max = LONG(0);

## defn gc_root_count
oop gc_root_count = LONG(0);

## defn gc_roots
oop gc_roots = LONG(0);

## defn gc_bytes_free
oop gc_bytes_free = LONG(0);

## defn gc_bytes_used
oop gc_bytes_used = LONG(0);

## defn gc_objects_live
oop gc_objects_live = LONG(0);

## defn gc_frequency
oop gc_frequency = LONG(32768);

## defn gc_quantum
oop gc_quantum = LONG(51200);

## defn stderr
oop stderr = LONG(0);

## defn stdout
oop stdout = LONG(0);

## defn stdin
oop stdin = LONG(0);

## defn input
oop input = LONG(0);

## defn arguments
oop arguments = LONG(0);

## defn isatty
extern oop isatty();
oop isatty$stub = (oop)&isatty;

## defn snprintf
extern oop snprintf();
oop snprintf$stub = (oop)&snprintf;

## defn sprintf
extern oop sprintf();
oop sprintf$stub = (oop)&sprintf;

## defn fprintf
extern oop fprintf();
oop fprintf$stub = (oop)&fprintf;

## defn printf
extern oop printf();
oop printf$stub = (oop)&printf;

## defn memmove
extern oop memmove();
oop memmove$stub = (oop)&memmove;

## defn memcpy
extern oop memcpy();
oop memcpy$stub = (oop)&memcpy;

## defn memset
extern oop memset();
oop memset$stub = (oop)&memset;

## defn free
extern oop free();
oop free$stub = (oop)&free;

## defn realloc
extern oop realloc();
oop realloc$stub = (oop)&realloc;

## defn malloc
extern oop malloc();
oop malloc$stub = (oop)&malloc;

## defn exit
extern oop exit();
oop exit$stub = (oop)&exit;

## defn abort
extern oop abort();
oop abort$stub = (oop)&abort;

/* eval2-utf8.c - UTF-8 enabled Maru evaluator */
/* Generated from eval.l using emit-c.l backend */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>
#include <locale.h>

/* UTF-8 support macros */
#if defined(WIN32)
# define swnprintf(BUF, SIZE, FMT, ARG) swprintf(BUF, FMT, ARG)
#else
# define swnprintf swprintf
#endif

/* Generated by Maru compiler */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef union Object *oop;
#define nil ((oop)0)
#define LONG(n) ((oop)(((long)(n) << 1) | 1))
#define getLong(x) ((long)(x) >> 1)

/* Forward declarations */
oop compile-eval2-utf8();
oop make-gc-let*();
oop make-gc-unprotectors();
oop make-gc-protectors();
oop gen-env-c();
oop c-temp-name();
oop c-newline();
oop c-indent();
oop gen-env();
oop gen-param();
oop gen-address-of();
oop gen-return();
oop gen-set();
oop gen-while();
oop gen-if();
oop gen-or();
oop gen-and();
oop gen-let();
oop gen-let-binding();
oop generate-ternary();
oop generate-binary();
oop generate-unary();
oop generate-nullary();
oop gen-move();
oop gen-arg();
oop gen-tmp();
oop gen-tmp-prog();
oop free-temps();
oop free-temp();
oop alloc-temp();
oop new-temp();
oop free-args();
oop new-arg();
oop new-param();
oop compiler();
oop temp?();
oop TI32();
oop LI32();
oop GI32();
oop LABEL();
oop temp-label-name();
oop mangle-label();
oop digit-for();
oop %define-emit-params();
oop %define-emit-param-name();
oop define-operand-make-setters();
oop extern?();
oop extern();
oop symbol->type-name();
oop string->type-name();
oop contents-of-file-named();
oop contents-to-file-named();
oop require();
oop load();
oop find-and-read();
oop pval();
oop equal-lists();
oop equal();
oop align();
oop sum();
oop min();
oop max();
oop string-search();
oop array-search();
oop %search();
oop string-sort();
oop array-sort();
oop %sort();
oop %partition();
oop array-append-all();
oop character->string();
oop list->string();
oop array->list();
oop array->string();
oop string->number();
oop string->number-base();
oop %loop-steps();
oop %loop-inits();
oop for-each-with();
oop %generic-do();
oop zip-assocs();
oop zip();
oop list-reverse!();
oop member?();
oop %add-multimethod();
oop generic();
oop printf();
oop dump-until();
oop dumpln();
oop println();
oop <selector>-add-method();
oop selector();
oop <selector>-inherit();
oop selector?();
oop make-instance-accessors();
oop make-with-form();
oop global?();
oop environment-find();
oop environment-define();
oop environment();
oop variable();
oop fixed();
oop variable?();
oop expr?();
oop double?();
oop long?();
oop %make-make-inits();
oop %make-accessors();
oop %make-unsafe-accessor();
oop %make-safe-accessor();
oop %accessor();
oop %make-accessor();
oop %typecheck();
oop inherits-from();
oop fields-of-type();
oop sanity-check-structure-fields();
oop type-name-of();
oop name-of-type();
oop %allocate-type();
oop %cond();
oop %progn();
oop %let*();
oop %let*bindings();
oop %let*unpack();
oop %let*getters();
oop foldr();
oop map*();
oop map2-with();
oop with-map2();
oop with2-map();
oop map-with2();
oop with-map();
oop map-with();
oop reverse-map-with();
oop reverse-with-map();
oop reverse-map();
oop map();
oop mapN();
oop map1();
oop array-append();
oop list->array();
oop %list->array();
oop list-length();
oop macro-expand();
oop concat-symbols();
oop concat-symbol();
oop concat-strings();
oop concat-string();
oop concat-list();
oop assq();
oop memq();
oop cddddr();
oop cadddr();
oop caaddr();
oop caddar();
oop cdddr();
oop caddr();
oop cdadr();
oop caadr();
oop cadar();
oop cddr();
oop cdar();
oop cadr();
oop caar();
oop %error();
oop error();
oop list();
oop dump();
oop print();

/* defn compile-eval2-utf8 */
oop compile-eval2-utf8() {
  oop _acc = nil;

static long ___L__2652__compile_2Deval2_2Dutf8_2El__10[] = {

static long ___L__2653__compile_2Deval2_2Dutf8_2El__10[] = {
  "/* eval2-utf8.c - UTF-8 enabled Maru evaluator */"
,
    _acc = (oop)___L__2653__compile_2Deval2_2Dutf8_2El__10;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2654__compile_2Deval2_2Dutf8_2El__11[] = {

static long ___L__2655__compile_2Deval2_2Dutf8_2El__11[] = {
  "/* Generated from eval.l using emit-c.l backend */"
,
    _acc = (oop)___L__2655__compile_2Deval2_2Dutf8_2El__11;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2656__compile_2Deval2_2Dutf8_2El__12[] = {
  _acc = _println;
  _acc = ((oop (*)())_acc)();

static long ___L__2657__compile_2Deval2_2Dutf8_2El__15[] = {

static long ___L__2658__compile_2Deval2_2Dutf8_2El__15[] = {
  "#define _GNU_SOURCE"
,
    _acc = (oop)___L__2658__compile_2Deval2_2Dutf8_2El__15;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2659__compile_2Deval2_2Dutf8_2El__16[] = {

static long ___L__2660__compile_2Deval2_2Dutf8_2El__16[] = {
  "#include <stdio.h>"
,
    _acc = (oop)___L__2660__compile_2Deval2_2Dutf8_2El__16;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2661__compile_2Deval2_2Dutf8_2El__17[] = {

static long ___L__2662__compile_2Deval2_2Dutf8_2El__17[] = {
  "#include <stdlib.h>"
,
    _acc = (oop)___L__2662__compile_2Deval2_2Dutf8_2El__17;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2663__compile_2Deval2_2Dutf8_2El__18[] = {

static long ___L__2664__compile_2Deval2_2Dutf8_2El__18[] = {
  "#include <string.h>"
,
    _acc = (oop)___L__2664__compile_2Deval2_2Dutf8_2El__18;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2665__compile_2Deval2_2Dutf8_2El__19[] = {

static long ___L__2666__compile_2Deval2_2Dutf8_2El__19[] = {
  "#include <wchar.h>"
,
    _acc = (oop)___L__2666__compile_2Deval2_2Dutf8_2El__19;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2667__compile_2Deval2_2Dutf8_2El__20[] = {

static long ___L__2668__compile_2Deval2_2Dutf8_2El__20[] = {
  "#include <locale.h>"
,
    _acc = (oop)___L__2668__compile_2Deval2_2Dutf8_2El__20;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2669__compile_2Deval2_2Dutf8_2El__21[] = {
  _acc = _println;
  _acc = ((oop (*)())_acc)();

static long ___L__2670__compile_2Deval2_2Dutf8_2El__24[] = {

static long ___L__2671__compile_2Deval2_2Dutf8_2El__24[] = {
  "/* UTF-8 support macros */"
,
    _acc = (oop)___L__2671__compile_2Deval2_2Dutf8_2El__24;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2672__compile_2Deval2_2Dutf8_2El__25[] = {

static long ___L__2673__compile_2Deval2_2Dutf8_2El__25[] = {
  "#if defined(WIN32)"
,
    _acc = (oop)___L__2673__compile_2Deval2_2Dutf8_2El__25;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2674__compile_2Deval2_2Dutf8_2El__26[] = {

static long ___L__2675__compile_2Deval2_2Dutf8_2El__26[] = {
  "# define swnprintf(BUF, SIZE, FMT, ARG) swprintf(BUF, FMT, ARG)"
,
    _acc = (oop)___L__2675__compile_2Deval2_2Dutf8_2El__26;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2676__compile_2Deval2_2Dutf8_2El__27[] = {

static long ___L__2677__compile_2Deval2_2Dutf8_2El__27[] = {
  "#else"
,
    _acc = (oop)___L__2677__compile_2Deval2_2Dutf8_2El__27;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2678__compile_2Deval2_2Dutf8_2El__28[] = {

static long ___L__2679__compile_2Deval2_2Dutf8_2El__28[] = {
  "# define swnprintf swprintf"
,
    _acc = (oop)___L__2679__compile_2Deval2_2Dutf8_2El__28;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2680__compile_2Deval2_2Dutf8_2El__29[] = {

static long ___L__2681__compile_2Deval2_2Dutf8_2El__29[] = {
  "#endif"
,
    _acc = (oop)___L__2681__compile_2Deval2_2Dutf8_2El__29;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2682__compile_2Deval2_2Dutf8_2El__30[] = {
  _acc = _println;
  _acc = ((oop (*)())_acc)();

static long ___L__2683__compile_2Deval2_2Dutf8_2El__33[] = {
  _acc = __2Aglobals_2A;
  _tmp0 = _acc;
  _acc = _gen_2Denv_2Dc;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2684__compile_2Deval2_2Dutf8_2El__36[] = {

static long ___L__2685__compile_2Deval2_2Dutf8_2El__36[] = {
  "/* UTF-8 initialization in main */"
,
    _acc = (oop)___L__2685__compile_2Deval2_2Dutf8_2El__36;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2686__compile_2Deval2_2Dutf8_2El__37[] = {

static long ___L__2687__compile_2Deval2_2Dutf8_2El__37[] = {
  "int main(int argc, char **argv) {"
,
    _acc = (oop)___L__2687__compile_2Deval2_2Dutf8_2El__37;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2688__compile_2Deval2_2Dutf8_2El__38[] = {

static long ___L__2689__compile_2Deval2_2Dutf8_2El__38[] = {
  "    setlocale(LC_ALL, \"\");"
,
    _acc = (oop)___L__2689__compile_2Deval2_2Dutf8_2El__38;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2690__compile_2Deval2_2Dutf8_2El__39[] = {

static long ___L__2691__compile_2Deval2_2Dutf8_2El__39[] = {
  "    return eval_main(argc, argv);"
,
    _acc = (oop)___L__2691__compile_2Deval2_2Dutf8_2El__39;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2692__compile_2Deval2_2Dutf8_2El__40[] = {

static long ___L__2693__compile_2Deval2_2Dutf8_2El__40[] = {
  "}"
,
    _acc = (oop)___L__2693__compile_2Deval2_2Dutf8_2El__40;
  _tmp0 = _acc;
  _acc = _println;
  _tmp0 = _tmp0;
  _acc = ((oop (*)())_acc)(_arg0);

static long ___L__2694__compile_2Deval2_2Dutf8_2El__41[] = {
  _acc = _println;
  _acc = ((oop (*)())_acc)();
return _acc;
}

oop compile-eval2-utf8 = (oop)compile-eval2-utf8;
/* defn gc-let* */
/* form gc-let* */
/* defn make-gc-let* */
oop make-gc-let*(oop _param0, oop _param1) {
  oop _acc = nil;

[31;1merror: selector gen has no method for <symbol>: (let <compiler>)[m
[32m[?7lboot.l:24   [0m (abort)
[?7h[32m[?7lemit.l:311  [0m (error "selector " (Fixed<quote> gen) " has no method for " (array-at %type-names (type-of (car args))) ": " (cons (car args) (map name-of-type (map type-of (cdr args)))))
[?7h[32m[?7lboot.l:517  [0m (apply (Fixed<or> (array-at (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (<selector>-inherit (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (oop-at (%typecheck <selector> self) 2)) arguments)
[?7h[32m[?7lemit.l:346  [0m (gen expr comp)
[?7h[32m[?7lboot.l:207  [0m (function (car list) a)
[?7h[32m[?7lboot.l:207  [0m (Fixed<let> ((head (function (car list) a))) (cons head (map-with function (cdr list) a)))
[?7h[32m[?7lboot.l:206  [0m (Fixed<if> (pair? list) (Fixed<let> ((head (function (car list) a))) (cons head (map-with function (cdr list) a))))
[?7h[32m[?7lemit.l:488  [0m (map-with gen-tmp (cdr self) comp)
[?7h[32m[?7lemit.l:488  [0m (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))
[?7h[32m[?7lemit.l:486  [0m (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))
[?7h[32m[?7lemit.l:484  [0m (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))))
[?7h[32m[?7lemit.l:481  [0m (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))))
[?7h[32m[?7lemit.l:481  [0m (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))))))
[?7h[32m[?7lemit.l:481  [0m (Fixed<let> ((head (car self))) (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))))))
[?7h[32m[?7l...         [0m (Fixed<let> () (Fixed<and> (= 0 (optimised)) (Fixed<let> ((source (oop-at self 2))) (Fixed<and> (!= *label-source* source) (car source) (Fixed<let> () (Fixed<set> *label-source* source) (gen comp DEFLABEL (LABEL (temp-label-name))))))) (Fixed<let> ((head (car self))) (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))))))))
[?7h[32m[?7l...         [0m (Fixed<let> () (Fixed<let> () (Fixed<and> (= 0 (optimised)) (Fixed<let> ((source (oop-at self 2))) (Fixed<and> (!= *label-source* source) (car source) (Fixed<let> () (Fixed<set> *label-source* source) (gen comp DEFLABEL (LABEL (temp-label-name))))))) (Fixed<let> ((head (car self))) (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))))))))
[?7h[32m[?7lboot.l:517  [0m (apply (Fixed<or> (array-at (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (<selector>-inherit (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (oop-at (%typecheck <selector> self) 2)) arguments)
[?7h[32m[?7lemit.l:346  [0m (gen expr comp)
[?7h[32m[?7lboot.l:207  [0m (function (car list) a)
[?7h[32m[?7lboot.l:207  [0m (Fixed<let> ((head (function (car list) a))) (cons head (map-with function (cdr list) a)))
[?7h[32m[?7lboot.l:206  [0m (Fixed<if> (pair? list) (Fixed<let> ((head (function (car list) a))) (cons head (map-with function (cdr list) a))))
[?7h[32m[?7lemit.l:488  [0m (map-with gen-tmp (cdr self) comp)
[?7h[32m[?7lemit.l:488  [0m (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))
[?7h[32m[?7lemit.l:486  [0m (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))
[?7h[32m[?7lemit.l:484  [0m (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))))
[?7h[32m[?7lemit.l:481  [0m (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))))
[?7h[32m[?7lemit.l:481  [0m (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))))))
[?7h[32m[?7lemit.l:481  [0m (Fixed<let> ((head (car self))) (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))))))
[?7h[32m[?7l...         [0m (Fixed<let> () (Fixed<and> (= 0 (optimised)) (Fixed<let> ((source (oop-at self 2))) (Fixed<and> (!= *label-source* source) (car source) (Fixed<let> () (Fixed<set> *label-source* source) (gen comp DEFLABEL (LABEL (temp-label-name))))))) (Fixed<let> ((head (car self))) (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))))))))
[?7h[32m[?7l...         [0m (Fixed<let> () (Fixed<let> () (Fixed<and> (= 0 (optimised)) (Fixed<let> ((source (oop-at self 2))) (Fixed<and> (!= *label-source* source) (car source) (Fixed<let> () (Fixed<set> *label-source* source) (gen comp DEFLABEL (LABEL (temp-label-name))))))) (Fixed<let> ((head (car self))) (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))))))))
[?7h[32m[?7lboot.l:517  [0m (apply (Fixed<or> (array-at (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (<selector>-inherit (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (oop-at (%typecheck <selector> self) 2)) arguments)
[?7h[32m[?7lemit.l:346  [0m (gen expr comp)
[?7h[32m[?7lboot.l:207  [0m (function (car list) a)
[?7h[32m[?7lboot.l:207  [0m (Fixed<let> ((head (function (car list) a))) (cons head (map-with function (cdr list) a)))
[?7h[32m[?7lboot.l:206  [0m (Fixed<if> (pair? list) (Fixed<let> ((head (function (car list) a))) (cons head (map-with function (cdr list) a))))
[?7h[32m[?7lemit.l:488  [0m (map-with gen-tmp (cdr self) comp)
[?7h[32m[?7lemit.l:488  [0m (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))
[?7h[32m[?7lemit.l:486  [0m (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))
[?7h[32m[?7lemit.l:484  [0m (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))))
[?7h[32m[?7lemit.l:481  [0m (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))))
[?7h[32m[?7lemit.l:481  [0m (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))))))
[?7h[32m[?7lemit.l:481  [0m (Fixed<let> ((head (car self))) (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))))))
[?7h[32m[?7l...         [0m (Fixed<let> () (Fixed<and> (= 0 (optimised)) (Fixed<let> ((source (oop-at self 2))) (Fixed<and> (!= *label-source* source) (car source) (Fixed<let> () (Fixed<set> *label-source* source) (gen comp DEFLABEL (LABEL (temp-label-name))))))) (Fixed<let> ((head (car self))) (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))))))))
[?7h[32m[?7l...         [0m (Fixed<let> () (Fixed<let> () (Fixed<and> (= 0 (optimised)) (Fixed<let> ((source (oop-at self 2))) (Fixed<and> (!= *label-source* source) (car source) (Fixed<let> () (Fixed<set> *label-source* source) (gen comp DEFLABEL (LABEL (temp-label-name))))))) (Fixed<let> ((head (car self))) (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))))))))
[?7h[32m[?7lboot.l:517  [0m (apply (Fixed<or> (array-at (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (<selector>-inherit (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (oop-at (%typecheck <selector> self) 2)) arguments)
[?7h[32m[?7lemit.l:422  [0m (gen (caddr expr) comp)
[?7h[32m[?7lemit.l:418  [0m (Fixed<let> ((a (LABEL (temp-label-name))) (b (LABEL (temp-label-name)))) (gen (cadr expr) comp) (gen comp BF a) (gen (caddr expr) comp) (gen comp BR b) (gen comp DEFLABEL a) (Fixed<let> ((_list_ (cdddr expr))) (Fixed<while> _list_ (Fixed<let> ((stmt (car _list_))) (gen stmt comp)) (Fixed<set> _list_ (cdr _list_)))) (gen comp DEFLABEL b))
[?7h[32m[?7lemit.l:487  [0m (op self comp)
[?7h[32m[?7lemit.l:486  [0m (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))
[?7h[32m[?7lemit.l:484  [0m (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))))
[?7h[32m[?7lemit.l:481  [0m (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))))
[?7h[32m[?7lemit.l:481  [0m (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))))))
[?7h[32m[?7lemit.l:481  [0m (Fixed<let> ((head (car self))) (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))))))
[?7h[32m[?7l...         [0m (Fixed<let> () (Fixed<and> (= 0 (optimised)) (Fixed<let> ((source (oop-at self 2))) (Fixed<and> (!= *label-source* source) (car source) (Fixed<let> () (Fixed<set> *label-source* source) (gen comp DEFLABEL (LABEL (temp-label-name))))))) (Fixed<let> ((head (car self))) (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg)))))))))))
[?7h[32m[?7l...         [0m (Fixed<let> () (Fixed<let> () (Fixed<and> (= 0 (optimised)) (Fixed<let> ((source (oop-at self 2))) (Fixed<and> (!= *label-source* source) (car source) (Fixed<let> () (Fixed<set> *label-source* source) (gen comp DEFLABEL (LABEL (temp-label-name))))))) (Fixed<let> ((head (car self))) (Fixed<let> ((arity (- (list-length self) 1))) (Fixed<let> ((op (Fixed<and> (variable? head) (cadr (assq (oop-at (%typecheck <variable> head) 1) (array-at operators arity)))))) (Fixed<if> op ((array-at generators arity) op (cdr self) comp) (Fixed<if> (Fixed<set> op (cdr (assq head forms))) (op self comp) (Fixed<let> ((tmps (map-with gen-tmp (cdr self) comp))) (Fixed<let> ((args (map-with gen-arg (cdr self) comp))) (Fixed<let> ((func (gen (car self) comp))) (Fixed<let> ((narg (list-length args))) (map2-with gen-move tmps args comp) (free-temps comp tmps) (free-args comp args) (gen comp CALL narg))))))))))))
[?7h[32m[?7lboot.l:517  [0m (apply (Fixed<or> (array-at (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (<selector>-inherit (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (oop-at (%typecheck <selector> self) 2)) arguments)
[?7h[32m[?7lemit-c.l:222[0m (gen e comp)
[?7h[32m[?7lemit-c.l:222[0m (Fixed<let> ((e (car _list_))) (gen e comp))
[?7h[32m[?7lemit-c.l:222[0m (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))
[?7h[32m[?7lemit-c.l:222[0m (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_))))
[?7h[32m[?7lemit-c.l:190[0m (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<if> main (println "int main(int argc, char **argv) {") (Fixed<let> () (print "oop " name "(") (Fixed<let> ((first 1)) (Fixed<let> ((_list_ params)) (Fixed<while> _list_ (Fixed<let> ((param (car _list_))) (Fixed<and> (not first) (print ", ")) (Fixed<set> first ()) (print "oop _param" (>> (oop-at (%typecheck <TI32> param) 0) 2))) (Fixed<set> _list_ (cdr _list_))))) (println ") {"))) (Fixed<set> *c-indent* 1) (c-indent) (println "oop _acc = nil;") (Fixed<let> ((max-args (oop-at (%typecheck <compiler> comp) 3))) (Fixed<let> ((i 0) (_limit_ (>> max-args 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _arg" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((max-temps (oop-at (%typecheck <compiler> comp) 5))) (Fixed<let> ((i 0) (_limit_ (>> max-temps 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _tmp" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (Fixed<let> () (println (oop-at (%typecheck <compiler> comp) 7) ":") (c-indent))) (Fixed<if> main (println "return 0;") (println "return _acc;")) (Fixed<set> *c-indent* 0) (println "}") (println) (Fixed<or> main (println "oop " name " = (oop)" name ";")))
[?7h[32m[?7lemit-c.l:190[0m (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<if> main (println "int main(int argc, char **argv) {") (Fixed<let> () (print "oop " name "(") (Fixed<let> ((first 1)) (Fixed<let> ((_list_ params)) (Fixed<while> _list_ (Fixed<let> ((param (car _list_))) (Fixed<and> (not first) (print ", ")) (Fixed<set> first ()) (print "oop _param" (>> (oop-at (%typecheck <TI32> param) 0) 2))) (Fixed<set> _list_ (cdr _list_))))) (println ") {"))) (Fixed<set> *c-indent* 1) (c-indent) (println "oop _acc = nil;") (Fixed<let> ((max-args (oop-at (%typecheck <compiler> comp) 3))) (Fixed<let> ((i 0) (_limit_ (>> max-args 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _arg" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((max-temps (oop-at (%typecheck <compiler> comp) 5))) (Fixed<let> ((i 0) (_limit_ (>> max-temps 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _tmp" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (Fixed<let> () (println (oop-at (%typecheck <compiler> comp) 7) ":") (c-indent))) (Fixed<if> main (println "return 0;") (println "return _acc;")) (Fixed<set> *c-indent* 0) (println "}") (println) (Fixed<or> main (println "oop " name " = (oop)" name ";"))))
[?7h[32m[?7lemit-c.l:190[0m (Fixed<let> ((body (cddr defn))) (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<if> main (println "int main(int argc, char **argv) {") (Fixed<let> () (print "oop " name "(") (Fixed<let> ((first 1)) (Fixed<let> ((_list_ params)) (Fixed<while> _list_ (Fixed<let> ((param (car _list_))) (Fixed<and> (not first) (print ", ")) (Fixed<set> first ()) (print "oop _param" (>> (oop-at (%typecheck <TI32> param) 0) 2))) (Fixed<set> _list_ (cdr _list_))))) (println ") {"))) (Fixed<set> *c-indent* 1) (c-indent) (println "oop _acc = nil;") (Fixed<let> ((max-args (oop-at (%typecheck <compiler> comp) 3))) (Fixed<let> ((i 0) (_limit_ (>> max-args 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _arg" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((max-temps (oop-at (%typecheck <compiler> comp) 5))) (Fixed<let> ((i 0) (_limit_ (>> max-temps 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _tmp" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (Fixed<let> () (println (oop-at (%typecheck <compiler> comp) 7) ":") (c-indent))) (Fixed<if> main (println "return 0;") (println "return _acc;")) (Fixed<set> *c-indent* 0) (println "}") (println) (Fixed<or> main (println "oop " name " = (oop)" name ";")))))
[?7h[32m[?7lemit-c.l:190[0m (Fixed<let> ((defn (oop-at (%typecheck <expr> self) 1))) (Fixed<let> ((body (cddr defn))) (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<if> main (println "int main(int argc, char **argv) {") (Fixed<let> () (print "oop " name "(") (Fixed<let> ((first 1)) (Fixed<let> ((_list_ params)) (Fixed<while> _list_ (Fixed<let> ((param (car _list_))) (Fixed<and> (not first) (print ", ")) (Fixed<set> first ()) (print "oop _param" (>> (oop-at (%typecheck <TI32> param) 0) 2))) (Fixed<set> _list_ (cdr _list_))))) (println ") {"))) (Fixed<set> *c-indent* 1) (c-indent) (println "oop _acc = nil;") (Fixed<let> ((max-args (oop-at (%typecheck <compiler> comp) 3))) (Fixed<let> ((i 0) (_limit_ (>> max-args 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _arg" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((max-temps (oop-at (%typecheck <compiler> comp) 5))) (Fixed<let> ((i 0) (_limit_ (>> max-temps 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _tmp" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (Fixed<let> () (println (oop-at (%typecheck <compiler> comp) 7) ":") (c-indent))) (Fixed<if> main (println "return 0;") (println "return _acc;")) (Fixed<set> *c-indent* 0) (println "}") (println) (Fixed<or> main (println "oop " name " = (oop)" name ";"))))))
[?7h[32m[?7lemit-c.l:190[0m (Fixed<let> ((main (= (Fixed<quote> main) name))) (Fixed<let> ((defn (oop-at (%typecheck <expr> self) 1))) (Fixed<let> ((body (cddr defn))) (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<if> main (println "int main(int argc, char **argv) {") (Fixed<let> () (print "oop " name "(") (Fixed<let> ((first 1)) (Fixed<let> ((_list_ params)) (Fixed<while> _list_ (Fixed<let> ((param (car _list_))) (Fixed<and> (not first) (print ", ")) (Fixed<set> first ()) (print "oop _param" (>> (oop-at (%typecheck <TI32> param) 0) 2))) (Fixed<set> _list_ (cdr _list_))))) (println ") {"))) (Fixed<set> *c-indent* 1) (c-indent) (println "oop _acc = nil;") (Fixed<let> ((max-args (oop-at (%typecheck <compiler> comp) 3))) (Fixed<let> ((i 0) (_limit_ (>> max-args 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _arg" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((max-temps (oop-at (%typecheck <compiler> comp) 5))) (Fixed<let> ((i 0) (_limit_ (>> max-temps 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _tmp" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (Fixed<let> () (println (oop-at (%typecheck <compiler> comp) 7) ":") (c-indent))) (Fixed<if> main (println "return 0;") (println "return _acc;")) (Fixed<set> *c-indent* 0) (println "}") (println) (Fixed<or> main (println "oop " name " = (oop)" name ";")))))))
[?7h[32m[?7l...         [0m (Fixed<let> () (Fixed<let> ((main (= (Fixed<quote> main) name))) (Fixed<let> ((defn (oop-at (%typecheck <expr> self) 1))) (Fixed<let> ((body (cddr defn))) (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<if> main (println "int main(int argc, char **argv) {") (Fixed<let> () (print "oop " name "(") (Fixed<let> ((first 1)) (Fixed<let> ((_list_ params)) (Fixed<while> _list_ (Fixed<let> ((param (car _list_))) (Fixed<and> (not first) (print ", ")) (Fixed<set> first ()) (print "oop _param" (>> (oop-at (%typecheck <TI32> param) 0) 2))) (Fixed<set> _list_ (cdr _list_))))) (println ") {"))) (Fixed<set> *c-indent* 1) (c-indent) (println "oop _acc = nil;") (Fixed<let> ((max-args (oop-at (%typecheck <compiler> comp) 3))) (Fixed<let> ((i 0) (_limit_ (>> max-args 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _arg" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((max-temps (oop-at (%typecheck <compiler> comp) 5))) (Fixed<let> ((i 0) (_limit_ (>> max-temps 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _tmp" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (Fixed<let> () (println (oop-at (%typecheck <compiler> comp) 7) ":") (c-indent))) (Fixed<if> main (println "return 0;") (println "return _acc;")) (Fixed<set> *c-indent* 0) (println "}") (println) (Fixed<or> main (println "oop " name " = (oop)" name ";"))))))))
[?7h[32m[?7l...         [0m (Fixed<let> () (Fixed<let> () (Fixed<let> ((main (= (Fixed<quote> main) name))) (Fixed<let> ((defn (oop-at (%typecheck <expr> self) 1))) (Fixed<let> ((body (cddr defn))) (Fixed<let> ((comp (compiler (+ 1 (oop-at (%typecheck <compiler> ocomp) 0))))) (Fixed<let> ((params (map-with gen-param (cadr defn) comp))) (Fixed<if> main (println "int main(int argc, char **argv) {") (Fixed<let> () (print "oop " name "(") (Fixed<let> ((first 1)) (Fixed<let> ((_list_ params)) (Fixed<while> _list_ (Fixed<let> ((param (car _list_))) (Fixed<and> (not first) (print ", ")) (Fixed<set> first ()) (print "oop _param" (>> (oop-at (%typecheck <TI32> param) 0) 2))) (Fixed<set> _list_ (cdr _list_))))) (println ") {"))) (Fixed<set> *c-indent* 1) (c-indent) (println "oop _acc = nil;") (Fixed<let> ((max-args (oop-at (%typecheck <compiler> comp) 3))) (Fixed<let> ((i 0) (_limit_ (>> max-args 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _arg" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((max-temps (oop-at (%typecheck <compiler> comp) 5))) (Fixed<let> ((i 0) (_limit_ (>> max-temps 2))) (Fixed<while> (< i _limit_) (c-indent) (println "oop _tmp" i " = nil;") (Fixed<set> i (+ i 1))))) (Fixed<let> ((_list_ body)) (Fixed<while> _list_ (Fixed<let> ((e (car _list_))) (gen e comp)) (Fixed<set> _list_ (cdr _list_)))) (Fixed<let> ((i 0) (_limit_ (oop-at (%typecheck <compiler> comp) 9))) (Fixed<while> (< i _limit_) (apply emit (array-at (oop-at (%typecheck <compiler> comp) 8) i)) (Fixed<set> i (+ i 1)))) (Fixed<and> (oop-at (%typecheck <compiler> comp) 7) (Fixed<let> () (println (oop-at (%typecheck <compiler> comp) 7) ":") (c-indent))) (Fixed<if> main (println "return 0;") (println "return _acc;")) (Fixed<set> *c-indent* 0) (println "}") (println) (Fixed<or> main (println "oop " name " = (oop)" name ";")))))))))
[?7h[32m[?7lboot.l:517  [0m (apply (Fixed<or> (array-at (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (<selector>-inherit (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (oop-at (%typecheck <selector> self) 2)) arguments)
[?7h[32m[?7lemit-c.l:299[0m (gen-definition value name comp)
[?7h[32m[?7lemit-c.l:296[0m (Fixed<let> ((name (oop-at (%typecheck <variable> (array-at vars index)) 0)) (value (oop-at (%typecheck <variable> (array-at vars index)) 1))) (println "/* defn " name " */") (gen-definition value name comp))
[?7h[32m[?7lemit-c.l:295[0m (Fixed<while> (<= 0 (Fixed<set> index (- index 1))) (Fixed<let> ((name (oop-at (%typecheck <variable> (array-at vars index)) 0)) (value (oop-at (%typecheck <variable> (array-at vars index)) 1))) (println "/* defn " name " */") (gen-definition value name comp)))
[?7h[32m[?7lemit-c.l:292[0m (Fixed<let> ((index (array-length vars))) (Fixed<while> (<= 0 (Fixed<set> index (- index 1))) (Fixed<let> ((name (oop-at (%typecheck <variable> (array-at vars index)) 0)) (value (oop-at (%typecheck <variable> (array-at vars index)) 1))) (println "/* defn " name " */") (gen-definition value name comp))))
[?7h[32m[?7lemit-c.l:292[0m (Fixed<let> ((comp (compiler 0))) (Fixed<let> ((index (array-length vars))) (Fixed<while> (<= 0 (Fixed<set> index (- index 1))) (Fixed<let> ((name (oop-at (%typecheck <variable> (array-at vars index)) 0)) (value (oop-at (%typecheck <variable> (array-at vars index)) 1))) (println "/* defn " name " */") (gen-definition value name comp)))))
[?7h[32m[?7lemit-c.l:292[0m (Fixed<let> ((vars (oop-at (%typecheck <env> env) 3))) (Fixed<let> ((comp (compiler 0))) (Fixed<let> ((index (array-length vars))) (Fixed<while> (<= 0 (Fixed<set> index (- index 1))) (Fixed<let> ((name (oop-at (%typecheck <variable> (array-at vars index)) 0)) (value (oop-at (%typecheck <variable> (array-at vars index)) 1))) (println "/* defn " name " */") (gen-definition value name comp))))))
[?7h[32m[?7lcompile-eval2-utf8.l:33[0m (gen-env-c *globals*)
[?7h[32m[?7lcompile-eval2-utf8.l:44[0m (compile-eval2-utf8)
[?7h