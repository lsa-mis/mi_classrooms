json.extract! room, :id, :rmrecnbr, :floor, :room_number, :rmtyp_description, :dept_id, :dept_grp, :dept_description, :square_feet, :instructional_seating_count, :visible, :building_bldrecnbr, :building_name, :created_at, :updated_at
json.url room_url(room, format: :json)
