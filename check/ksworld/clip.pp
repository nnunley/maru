(objects :root "1"
	(KSBox :ref "1" :size "4"
		(slot :keyClass "Symbol" :keyValue "transformation" :name "1" :valueClass "MatrixTransform2x3" :valueValue "1.0 0.0 100.0 0.0 1.0 50.0")
		(slot :keyClass "Symbol" :keyValue "extent" :name "2" :valueClass "Point" :valueValue "30.0@20.0")
		(slot :keyClass "Symbol" :keyValue "clipping" :name "3" :valueClass "True" :valueValue "true")
		(slot :keyClass "Symbol" :keyValue "contents" :name "4" :valueId "3"))
	(KSContentsCollection :ref "3" :size "2"
		(slot :name "1" :ref "4")
		(slot :name "2" :ref "11"))
	(KSBox :ref "4" :size "2"
		(slot :keyClass "Symbol" :keyValue "transformation" :name "1" :valueClass "MatrixTransform2x3" :valueValue "2.0 0.0 5.0 0.0 2.0 7.0")
		(slot :keyClass "Symbol" :keyValue "shape" :name "2" :valueId "6"))
	(KSShape :ref "6"
		(slot :name "elements" :ref "7"))
	(Array :ref "7" :size "1"
		(slot :name "1" :ref "8"))
	(GeziraPath :ref "8"
		(slot :name "floats" :ref "9")
		(slot :name "myFill" :ref "10"))
	(FloatArray :ref "9" :size "24" :value "AAAAGAAAAAAAAAAAAAAAAAAAAABBIAAAAAAAAEEgAAAAAAAAQSAAAAAAAABBIAAAQaAAAEEgAABBoAAAQSAAAEGgAAAAAAAAQaAAAAAAAABBoAAAAAAAAEGgAAAAAAAAAAAAAA==")
	(GeziraFillUniform :ref "10"
		(slot :class "Float" :name "alpha" :value "1.0")
		(slot :class "Float" :name "red" :value "1.0")
		(slot :class "Float" :name "green" :value "0.0")
		(slot :class "Float" :name "blue" :value "0.0"))
	(KSBox :ref "11" :size "2"
		(slot :keyClass "Symbol" :keyValue "transformation" :name "1" :valueClass "MatrixTransform2x3" :valueValue "1.0 0.0 5.0 0.0 1.0 0.0")
		(slot :keyClass "Symbol" :keyValue "shape" :name "2" :valueId "6")))
