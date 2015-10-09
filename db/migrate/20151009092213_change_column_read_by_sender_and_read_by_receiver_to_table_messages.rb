class ChangeColumnReadBySenderAndReadByReceiverToTableMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :read_by_receiver
    remove_column :messages, :read_by_sender
    add_column :messages, :read, :boolean, default: false
  end
end
