(objects :root "1"
	(KSBox :ref "1" :size "4"
		(slot :keyClass "Symbol" :keyValue "slow" :name "1" :valueId "2")
		(slot :keyClass "Symbol" :keyValue "slowCount" :name "2" :valueId "3")
		(slot :keyClass "Symbol" :keyValue "half" :name "3" :valueId "4")
		(slot :keyClass "Symbol" :keyValue "halfCount" :name "4" :valueId "5"))
	(KSEventStream :__code__ "timerE(1000)" :__dormant__ "false" :__homeObject__ "1" :__type__ "exprE" :ref "2")
	(KSEventStream :__code__ "0 fby slowCount' + 1 on slow" :__dormant__ "false" :__homeObject__ "1" :__type__ "exprE" :ref "3"
		(slot :keyClass "String" :keyValue "__currentValue__" :valueClass "SmallInteger" :valueValue "0"))
	(KSEventStream :__code__ "timerE(2.5)" :__dormant__ "false" :__homeObject__ "1" :__type__ "exprE" :ref "4")
	(KSEventStream :__code__ "0 fby halfCount' + 1 on half" :__dormant__ "false" :__homeObject__ "1" :__type__ "exprE" :ref "5"
		(slot :keyClass "String" :keyValue "__currentValue__" :valueClass "SmallInteger" :valueValue "0")))
