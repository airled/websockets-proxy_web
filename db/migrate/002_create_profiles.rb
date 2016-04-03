Sequel.migration do
  up do
    create_table :profiles do
      primary_key :id
      Integer :account_id
      String :name
      String :queue, unique: true
    end
  end

  down do
    drop_table :profiles
  end
end
