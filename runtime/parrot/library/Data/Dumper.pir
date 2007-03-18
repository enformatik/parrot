.sub __library_data_dumper_onload :load
    find_type $I0, "Data::Dumper"
    if $I0 > 1 goto END
    load_bytecode "library/Data/Dumper/Default.pir"
    newclass $P0, "Data::Dumper"
END:
    .return ()
.end

.namespace ["Data::Dumper"]

.sub dumper :method
    .param pmc dump
    .param string name           :optional
    .param int has_name          :opt_flag
    .param string indent         :optional
    .param int has_indent        :opt_flag
    .local pmc style

    if has_indent goto no_def_indent
    set indent, "    "
no_def_indent:
    # use a default name
    if has_name goto no_def_name
    set name, "VAR1"
no_def_name:
    # XXX: support different output styles
    find_type $I0, "Data::Dumper::Default"
    if $I0 < 1 goto ERROR2
    new style, $I0

    style."prepare"( self, indent )
    style."dumpWithName"( name, name, dump )

    print "\n"

    .return ( 1 )

ERROR2:
    print "can not find class Data::Dumper::Default!\n"
    end
    .return ( 0 )
ERROR:
    print "Syntax:\n"
    print "Data::Dumper::dumper( pmc )\n"
    print "Data::Dumper::dumper( pmc, name )\n"
    print "Data::Dumper::dumper( pmc, name, indent )\n"
    .return ( 0 )
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
