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
		set epO [get_object_name [get_pins $ep]]
		set cellMaxSlack [get_attr [get_pins $epO] max_slack]
		if {$cellMaxSlack==""} {set cellMaxSlack==1000}
		if {$cellMaxSlack < $slackLimit} {
			set cellMaxSlackARR($ecO) $cellMaxSlack
		}
	}
	return [array names cellMaxSlackARR]
}

proc getEndcellVIODeltaNetList {cell {slackLimit 0} {deltaLimit 10}} {
	array unset deltadlyARR 
	array set deltadlyARR ""
	array unset maxSlackARR
	array set maxSlackARR ""
	set pins ""
	set ICGattr [get_attr -q [get_cells $cell] is_clock_gating_check]
	if {$ICGattr=="true"} {
		set fanoutPin [get_pins -of $cell] -filter "direction==out"]
		set cc [all_fanout -qu -from [get_pins $fanoutPin ] -endpoints_only -flat -only_cells]
	} else {
		set cc [get_cells $cell]
	}
	set allpts [get_attr [get_attr [get_timing_paths -to [get_cells $cc]] points] object]
	foreach_in_colll ep $allpts  {
		set ecO [get_object_name [get_cells -q -of [get_pins $ep]]]
		set is_seq [get_attr [get_cells $ecO] is_sequential]
		if {$is_seq =="true"} {continue }
		set enO [get_object_name [get_nets -of $ep ]]
		set deltadly [get_attr [get_nets $enO] annotated_delay_delta_max] 
		set maxSlack [get_attr [get_nets $enO max_slack]]
		if {$deltadly==""} {set deltadly 0}
		if {$maxSlack==""} {set maxSlack==1000}
		if {$maxSlack< $slackLimit && $deltadly >= $deltaLimit} {
			set deltadlyARR($enO) $deltadly
		}
	}
	return [array names deltadlyARR]
}



proc getEndcellPathcellList {cell {slackLimit 0}} {
	array unset cellPathMaxSlackARR
	array set cellPathMaxSlackARR "" 
	set ICGattr [get_attr -q [get_cells $cell] is_clock_gating_check]
	if {$ICGattr=="true"}{
		set fanoutPin [get_pins -of $cell -filter "direction==out"]
		set startC [all_fanout -q -from [get_pins $fanoutPin] -endpoints_only -flat -only_cells]
	}else {
		set startC [get_cells $cell]
	}
	set allpts [get_attr [get_attr [get_timing_paths -to [get_cells $startC]] points] object]
	foreach_in_coll ep $allpts {
		set ecO [get_object_name [get_cells -q -of [get_pins $ep]]]
		set is_seq [get_attr [get_cells $ecO] is_sequential]
		if {$is_seq=="true"} {continue}
		set epO [get_object_name [get_pins $ep]]
		if {$cellMaxSlack==""} {set cellMaxSlack 1000}
		if {$cellMaxSlack < $slackLimit} {
			set cellPathMaxSlackARR($ecO) $cellMaxSlack
		}
		return [array names cellPathMaxSlackARR]
}


proc getMaxUseabledsizeRef {cell {vtKeep ""} {areaAmpFactor 2}} {
	global marginImproveEffort
	global stepSizeup
	array unset AREA_ARR
	array set AREA_ARR ""
	set indexList {}
	set origRef [get_attr [get_cells $cell] ref_name]
	set cellO [get_object_name [get_cells $cell]]
	set isSeqFlag [lsort -uniq [get_attr [get_lib_cells */$origRef] is_sequential]]
	if {$isSeqFlag=="true"} {return "origRef"}
	set refpatt [getRefpatt $origRef]
	if {$refpatt=="NA"} {
		return "$origRef"
	}

	set origRefpattList [split $refpatt ","]
	set vt [lindex $origRefpattList 0]
	set vtpost $vt
	if {[info exist marginImproveEffort ] && ($marginImproveEffort=="high") && ($vtKeep=="")} {
		if {![regexp {ULT} $vt]} {set vtpost ULT}
	}
	if {[info exist marginImproveEffort] && ($marginImproveEffort=="normal") && ($vtKeep=="")} {
	    if {![regexp {ULT|LVT} $vt]} {set vtpost LVT}
	}
	set vtpostRef [regsub $vt $origRef $vtpost]
	set type [lindex $origRefpattList 1]
	set root [lindex $origRefpattList 2]
	if {[lindex $origRefpattList 3]=="CK"} {
		set dsize [lindex $origRefpattList 4]
		set patt "HDB${vtpost}${type}_${root}_CK}"
	} elseif { 

	}

}

