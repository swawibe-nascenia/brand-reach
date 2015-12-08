class AddFirstNameLastNameInstedNameToInvitations < ActiveRecord::Migration
  def change
    remove_column :invitations, :name
    add_column :invitations, :first_name, :string
    add_column :invitations, :last_name, :string
  end
end
