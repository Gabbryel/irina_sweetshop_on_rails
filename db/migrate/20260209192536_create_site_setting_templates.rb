class CreateSiteSettingTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :site_setting_templates do |t|
      t.string :name, null: false
      t.text :description
      t.json :settings, default: {}
      t.boolean :active, default: false

      t.timestamps
    end
    
    add_index :site_setting_templates, :name, unique: true
    add_index :site_setting_templates, :active
  end
end
