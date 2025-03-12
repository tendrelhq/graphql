#!/usr/bin/env bash

unmanaged=(
  'crud_custag_create'
  'crud_custag_read_full'
  'crud_custag_read_min'
  'crud_customer_create'
  'crud_customer_read_full'
  'crud_customer_read_min'
  'crud_entityfield_create'
  'crud_entityfield_delete'
  'crud_entityfield_read_full'
  'crud_entityfield_read_min'
  'crud_entityfieldinstance_create'
  'crud_entityfieldinstance_delete'
  'crud_entityfieldinstance_read_full'
  'crud_entityfieldinstance_read_min'
  'crud_entityinstance_create'
  'crud_entityinstance_delete'
  'crud_entityinstance_read_full'
  'crud_entityinstance_read_min'
  'crud_entitytag_create'
  'crud_entitytag_delete'
  'crud_entitytag_read_full'
  'crud_entitytag_read_min'
  'crud_entitytemplate_create'
  'crud_entitytemplate_delete'
  'crud_entitytemplate_read_full'
  'crud_entitytemplate_read_min'
  'crud_location_create'
  'crud_location_read_full'
  'crud_location_read_min'
  'crud_systag_create'
  'crud_systag_read_full'
  'crud_systag_read_min'
  'func_test_entity'
  'func_test_entitytag'
  'func_test_instance'
  'func_test_location'
  'func_test_systag'
  'func_test_template'
  'func_test_template_field'
)

if [[ $1 != "--apply" ]]; then
  for f in "${unmanaged[@]}"; do
    psql -c "\\sf entity.${f}" >./sql/unmanaged/"$f".sql
  done
fi

if [[ $1 == "--apply" ]]; then
  for f in "${unmanaged[@]}"; do
    psql -f ./sql/unmanaged/"$f".sql
  done
fi
