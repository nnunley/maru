(objects :root "1"
	(KSBox :ref "1" :size "3"
		(slot :keyClass "Symbol" :keyValue "tableHandler" :name "1" :valueId "2")
		(slot :keyClass "Symbol" :keyValue "cellName" :name "2" :valueClass "Symbol" :valueValue "H1")
		(slot :keyClass "Symbol" :keyValue "shown" :name "3" :valueId "3"))
	(KSBox :ref "2" :size "2"
		(slot :keyClass "Symbol" :keyValue "ticks" :name "1" :valueId "4")
		(slot :keyClass "Symbol" :keyValue "H1" :name "2" :valueId "5"))
	(KSEventStream :__code__ "@tableHandler[@cellName].mapE((v) -> v * 10)" :__dormant__ "false" :__homeObject__ "1" :__type__ "mapE" :ref "3")
	(KSEventStream :__code__ "timerE(1)" :__dormant__ "false" :__homeObject__ "2" :__type__ "exprE" :ref "4")
	(KSEventStream :__code__ "0 fby H1' + 1 on ticks" :__dormant__ "false" :__homeObject__ "2" :__type__ "exprE" :ref "5"
		(slot :keyClass "String" :keyValue "__currentValue__" :valueClass "SmallInteger" :valueValue "0")))
