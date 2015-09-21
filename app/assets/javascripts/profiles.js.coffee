$ ->
  $('select#user_country').change (event) ->
    select_wrapper = $('#user_state_code_wrapper')

    $('select', select_wrapper).attr('disabled', true)

    country_code = $(this).val()

    url = "/subregion_options?parent_region=#{country_code}"
    console.log(url);
    select_wrapper.load(url)