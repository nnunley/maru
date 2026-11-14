(objects :root "1"
	(KSBox :ref "1" :size "3"
		(slot :keyClass "Symbol" :keyValue "ticks" :name "1" :valueId "2")
		(slot :keyClass "Symbol" :keyValue "count" :name "2" :valueId "3")
		(slot :keyClass "Symbol" :keyValue "shown" :name "3" :valueId "4")
		(data
			(span :data "0" :family "TimesNewRoman" :fill "0 0 0 255" :size "12" :style "0")))
	(KSEventStream :__code__ "timerE(1)" :__dormant__ "false" :__homeObject__ "1" :__type__ "exprE" :ref "2")
	(KSEventStream :__code__ "0 fby count' + 1 on ticks" :__dormant__ "false" :__homeObject__ "1" :__type__ "exprE" :ref "3"
		(slot :keyClass "String" :keyValue "__currentValue__" :valueClass "SmallInteger" :valueValue "0"))
	(KSEventStream :__code__ "@count.mapE((v) -> this.textContents(v.printString().concat('0')))" :__dormant__ "false" :__homeObject__ "1" :__type__ "mapE" :ref "4"))
