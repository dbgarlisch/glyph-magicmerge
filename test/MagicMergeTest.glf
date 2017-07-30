package require PWI_Glyph 2.17.0
source [file join [file dirname [info script]] ".." "MagicMerge.glf"]

magicMerge [pw::Grid getAll -type pw::Connector]
