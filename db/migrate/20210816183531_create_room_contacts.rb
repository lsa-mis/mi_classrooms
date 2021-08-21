class CreateRoomContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :room_contacts, id: false, primary_key: :rmrecnbr do |t|
      t.references :rmrecnbr, references: :rooms, null: false
      t.string  :rm_schd_cntct_name   
      t.string  :rm_schd_email        
      t.string  :rm_schd_cntct_phone  
      t.string  :rm_det_url           
      t.string  :rm_usage_guidlns_url 
      t.string  :rm_sppt_deptid       
      t.string  :rm_sppt_dept_descr   
      t.string  :rm_sppt_cntct_email  
      t.string  :rm_sppt_cntct_phone  
      t.string  :rm_sppt_cntct_url    

      t.timestamps
    end
    rename_column :room_contacts, :rmrecnbr_id, :rmrecnbr
    add_foreign_key :room_contacts, :rooms, column: 'rmrecnbr', primary_key: 'rmrecnbr'
  end
end
