prawn_document(:page_layout => :landscape, :margin => [10,10,10,10]) do |pdf|

 pdf.image "#{Rails.root}/app/assets/images/Logo.png", :fit => [99, 78]

 pdf.text_box 'Payment report', :at => [120, 510]

 pdf.move_down(10)

 table_data= [['Campaign Name', 'Date Billed', 'Transaction ID', 'Amount Received(INR)', 'Payment Status']]

 @brand_payments.each do |payment|
    table_data << [
                    payment.campaign.name,
                    payment.billed_date.present? ? payment.billed_date.strftime('%B %d, %Y') : 'NA',
                    sprintf('BP%05d', payment.id),
                    payment.amount_billed,
                    payment.status
                  ]
 end

  pdf.table(table_data, :column_widths => [100, 100, 150, 150, 100, 100], :cell_style => { inline_format: true, border_color: 'FFFFFF', padding: 3 }) do
          self.row_colors = %w(FFFFFF DDDDDD)
          row(0).background_color = 'D9D9D9'
          row(0).font_style = :bold
          self.header = true
  end

  # pdf.fill_rectangle [0, 0], 2000, 50
end