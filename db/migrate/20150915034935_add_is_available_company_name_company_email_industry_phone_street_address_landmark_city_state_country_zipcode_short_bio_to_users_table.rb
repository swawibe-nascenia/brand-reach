class AddIsAvailableCompanyNameCompanyEmailIndustryPhoneStreetAddressLandmarkCityStateCountryZipcodeShortBioToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :is_available, :boolean, default: true
    add_column :users, :company_name, :string
    add_column :users, :company_email, :string
    add_column :users, :industry, :string
    add_column :users, :phone, :integer
    add_column :users, :street_address, :string
    add_column :users, :landmark, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :country, :string
    add_column :users, :zip_code, :string
    add_column :users, :short_bio, :string
  end
end
