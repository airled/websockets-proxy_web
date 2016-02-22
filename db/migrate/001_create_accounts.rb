Sequel.migration do
  up do
    create_table :accounts do
      primary_key :id
      String :email, unique: true
      String :crypted_password
      String :role
      Boolean :confirmed, default: false
      Boolean :active, default: false
      String :queue, unique: true, default: nil
      Integer :port, unique: true, default: nil
    end
  end

  down do
    drop_table :accounts
  end
end
