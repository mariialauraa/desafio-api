class ChangeBallastTypeInProducts < ActiveRecord::Migration[7.1]
  def change
    change_column :products, :ballast, 'integer USING CAST(ballast AS integer)'
  end

  def down
    change_column :products, :ballast, :string
  end
end
