prawn_document(:page_layout => :landscape) do |pdf|
  table_data= [['Campaign Name', 'Post Likes', 'Reach', 'Comments', 'Shares', 'Campaign Starts', 'Campaign Ends']]

 @campaigns.each do |campaign|
    table_data << [
      campaign.name,
      campaign.number_of_likes,
      campaign.number_of_post_reach,
      campaign.number_of_comments,
      campaign.number_of_shares,
      campaign.start_date,
      campaign.end_date.present? ? campaign.end_date : 'NA'
    ]
 end

  pdf.table(table_data, :column_widths => [100, 100, 100, 100, 100, 100, 100], :cell_style => { inline_format: true, border_color: 'FFFFFF', padding: 3 }) do
          self.row_colors = %w(FFFFFF DDDDDD)
          row(0).background_color = 'D9D9D9'
          row(0).font_style = :bold
          self.header = true
        end
end