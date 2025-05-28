// Server
// Server
"spacjjxnnbdenmioeko67ffj4e-x2fqwohpz4ae5f4vgvdmzxxmwi.datawarehouse.fabric.microsoft.com" meta [IsParameterQuery=true, Type="Any", IsParameterQueryRequired=true]

// Database
// Database
"DIMSU_Lakehouse_Bronze" meta [IsParameterQuery=true, Type="Any", IsParameterQueryRequired=true]

// reg_bserv_bin_services
let
    Source = Sql.Database(Server, Database, [UnsafeTypeConversions = true]),
    pathway_reg_bserv_bin_services = Source{[Schema="pathway",Item="reg_bserv_bin_services"]}[Data]
in
    pathway_reg_bserv_bin_services

// Services register
// Services - Last audit after 1 Oct 2024
let
    Source = reg_bserv_bin_services,
    #"Added Custom" = Table.AddColumn(Source, "Audit date", each DateTime.From([c_audit_date]), DateTime.Type),
    #"Removed Other Columns" = Table.SelectColumns(#"Added Custom",{"property_key_link_to_property", "Audit date", "c_calculation_method", "c_frequency", "c_audit_trim_number", "c_auditors_name_and_comment", "c_other_audit_properties", "c_compaction", "c_compaction_mechanism", "c_chute", "c_of_spares_and_size", "c_building_name", "c_rates_information", "c_collection", "c_indemnity_doc_reference", "c_truck_size", "c_maximum_height", "c_other_restriction", "c_key", "c_key_box_location", "c_collection_day_exception", "c_owner_type", "c_drive_on", "c_storage_on_site", "c_perm_storage_on_street", "c_street_storage_trim_ref"}),
    #"Merged Property" = Table.NestedJoin(#"Removed Other Columns", {"property_key_link_to_property"}, property, {"property_key"}, "Property", JoinKind.Inner),
    #"Expanded Property" = Table.ExpandTableColumn(#"Merged Property", "Property", {"formatted_address", "address", "suburb", "street", "tpklpaprop", "parent_property_key", "formatted_owner_name", "owners_na_slab_1", "owners_na_slab_2", "owners_na_slab_3", "owners_na_slab_4", "owners_na_slab_5"}, {"formatted_address", "address", "suburb", "street", "tpklpaprop", "parent_property_key", "formatted_owner_name", "owners_na_slab_1", "owners_na_slab_2", "owners_na_slab_3", "owners_na_slab_4", "owners_na_slab_5"}),
    #"Merged Parent Property" = Table.NestedJoin(#"Expanded Property", {"parent_property_key"}, property, {"property_key"}, "Property", JoinKind.LeftOuter),
    #"Expanded Parent Property" = Table.ExpandTableColumn(#"Merged Parent Property", "Property", {"formatted_address", "address", "suburb", "street", "tpklpaprop", "formatted_owner_name", "owners_na_slab_1", "owners_na_slab_2", "owners_na_slab_3", "owners_na_slab_4", "owners_na_slab_5"}, {"parent_formatted_address", "parent_address", "parent_suburb", "parent_street", "parent_tpklpaprop", "parent_formatted_owner_name", "parent_owners_na_slab_1", "parent_owners_na_slab_2", "parent_owners_na_slab_3", "parent_owners_na_slab_4", "parent_owners_na_slab_5"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Expanded Parent Property",{{"Audit date", type date}}),
    #"Added Custom1" = Table.AddColumn(#"Changed Type", "Audited recently?", each if [Audit date] <> null and [Audit date] >= Date.AddYears(Date.From(DateTime.FixedLocalNow()), -1) then "Yes" else "No", Text.Type),
    #"Removed Other Columns1" = Table.SelectColumns(#"Added Custom1",{"Audit date", "c_calculation_method", "c_frequency", "c_audit_trim_number", "c_auditors_name_and_comment", "c_other_audit_properties", "c_compaction", "c_compaction_mechanism", "c_chute", "c_of_spares_and_size", "c_building_name", "c_rates_information", "c_collection", "c_indemnity_doc_reference", "c_truck_size", "c_maximum_height", "c_other_restriction", "c_key", "c_key_box_location", "c_collection_day_exception", "c_owner_type", "c_drive_on", "c_storage_on_site", "c_perm_storage_on_street", "c_street_storage_trim_ref", "formatted_address", "address", "suburb", "street", "tpklpaprop", "formatted_owner_name", "owners_na_slab_1", "owners_na_slab_2", "owners_na_slab_3", "owners_na_slab_4", "owners_na_slab_5", "parent_formatted_address", "parent_address", "parent_suburb", "parent_street", "parent_tpklpaprop", "parent_formatted_owner_name", "parent_owners_na_slab_1", "parent_owners_na_slab_2", "parent_owners_na_slab_3", "parent_owners_na_slab_4", "parent_owners_na_slab_5", "Audited recently?"})
in
    #"Removed Other Columns1"

// property
// Property
let
    Source = Sql.Database(Server, Database),
    pathway_property = Source{[Schema="pathway",Item="property"]}[Data],
    #"Filtered Rows" = Table.SelectRows(pathway_property, each [property_type] <> "STRCARSPC " and [property_type] <> "UTILITY   " and [status] = "C"),
    #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows",{"property_key", "formatted_address", "address", "suburb", "street", "status", "tpklpaprop", "parent_property_key", "parent_property_address", "formatted_owner_name", "owners_na_slab_1", "owners_na_slab_2", "owners_na_slab_3", "owners_na_slab_4", "owners_na_slab_5", "assessment", "assessment_key"})
in
    #"Removed Other Columns"