class CreateLoads < ActiveRecord::Migration[7.1]
  def change
    create_table :loads do |t|
      t.string :code
      t.date :delivery_date

      t.timestamps
    end
  end
end
