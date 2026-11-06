(objects :root "1"
	(KSBox :ref "1" :size "4"
		(slot :keyClass "Symbol" :keyValue "ticks" :name "1" :valueId "2")
		(slot :keyClass "Symbol" :keyValue "count" :name "2" :valueId "3")
		(slot :keyClass "Symbol" :keyValue "blinking" :name "3" :valueId "4")
		(slot :keyClass "Symbol" :keyValue "label" :name "4" :valueId "5"))
	(KSEventStream :__code__ "timerE(1)" :__dormant__ "false" :__homeObject__ "1" :__type__ "exprE" :ref "2")
	(KSEventStream :__code__ "0 fby count' + 1 on ticks" :__dormant__ "false" :__homeObject__ "1" :__type__ "exprE" :ref "3"
		(slot :keyClass "String" :keyValue "__currentValue__" :valueClass "SmallInteger" :valueValue "0"))
	(KSEventStream :__code__ "@ticks.doE(() -> this.blink())" :__dormant__ "false" :__homeObject__ "1" :__type__ "doE" :ref "4")
	(KSEventStream :__code__ "'hello'" :__dormant__ "false" :__homeObject__ "1" :__isBehavior__ "true" :__type__ "setter" :ref "5"
		(slot :keyClass "String" :keyValue "__currentValue__" :valueClass "String" :valueValue "hello")))
