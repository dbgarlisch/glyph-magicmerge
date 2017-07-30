#
# Copyright 2017 (c) Pointwise, Inc.
# All rights reserved.
#
# This sample script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
package require PWI_Glyph


proc magicMerge { cons {tol -1} } {
  if { $tol < 0.0 } {
    # Default tolerance
    set tol [pw::Grid getGridPointTolerance]
  }
  # Get the number of decimal digits needed by tol
  set prec [expr {abs(int(log10($tol)))}]
  # The format used to generate a point's dictionary key
  set keyFmt  "%.${prec}f %.${prec}f %.${prec}f"
  # Maps an XYZ point to a list of {con ndx} pairs that share the point
  set ptMap [dict create]
  # Run through cons building the map
  foreach con $cons {
    for {set ii 1} {$ii <= [$con getDimensions]} {incr ii} {
      set key [format $keyFmt {*}[$con getXYZ $ii]]
      dict lappend ptMap $key [list $con $ii]
    }
  }

  # Maps a con to its index split indices
  set splitMap [dict create]
  dict for {key conNdxs} $ptMap {
    if { 1 == [llength $conNdxs] } {
      # Point only used by a single con. We do not need to split it.
      continue
    }
    # Point used by two or more cons. Must split each con at its index.
    foreach conNdx $conNdxs {
      lassign $conNdx con ndx
      if { $ndx == 1 || $ndx == [$con getDimensions] } {
        # No need to split a connector at its endpoints
        continue
      }
      # Add ndx to con's list of split locations
      dict lappend splitMap $con $ndx
    }
  }

  # Accumulate all cons produced by splitting
  set splitCons [list]
  dict for {con ndxs} $splitMap {
    # Split the con at ndxs and append resulting cons to splitCons
    lappend splitCons {*}[$con split -I $ndxs]
  }

  # Remove duplicates from splitCons
  set splitCons [lsort -unique $splitCons]
  # Join all unique cons and capture results
  set joinCons [pw::Connector join -reject rejCons -keepDistribution $splitCons]

  # Cleanup con names
  set colxn [pw::Collection create]
  $colxn set $joinCons
  $colxn add $rejCons
  $colxn do setName "connnnnn-1"
  $colxn do setName "con-1"
  $colxn delete
}


# END SCRIPT

#
# DISCLAIMER:
# TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
# ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
# TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, WITH REGARD TO THIS SCRIPT. TO THE MAXIMUM EXTENT PERMITTED
# BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
# FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
# WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
# BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE
# USE OF OR INABILITY TO USE THIS SCRIPT EVEN IF POINTWISE HAS BEEN
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE
# FAULT OR NEGLIGENCE OF POINTWISE.
#
