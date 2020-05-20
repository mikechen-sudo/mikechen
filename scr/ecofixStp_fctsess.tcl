proc getEndcellAsStartPathPointList {cell {slackLimit 1000}} {
	array unset cellMaxSlackARR
	arry set cellMaxSlackARR
	set ICGattr [get_attr -q [get_cells $cell] is_clock_gating_check]
	if {$ICGattr=="true"} {
		set fanoutPin [get_pins -of $cell -filter "direction==out"]
		set startC [all_fanout -quiet -from [get_pins $fanoutPin] -endpoints_only -flat -only_cells]
	} else {
		set startC [get_cells $cell]
	}
	set allpts [get_attr [get_attr [get_timing_paths -from [get_cells $startC]] points] object]

	foreach_in_coll ep $allpts {
		set ecO [get_object_name [get_cells -q -of [get_pins $ep]]]
		set is_seq [get_attr [get_cells $ecO] is_sequential]
		if {$is_seq=="true"} {continue}


	}
}
