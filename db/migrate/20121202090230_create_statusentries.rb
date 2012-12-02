class CreateStatusentries < ActiveRecord::Migration
  def change
    create_table :statusentries do |t|
      t.string :parsed_staus
      t.text :raw_body

      t.timestamps
    end
  end
end
