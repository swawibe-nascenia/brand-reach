/**
 * Created by sumon on 10/2/15.
 */
$(function(){

//    toggle star of selected offers
    $('.make-all-stared').click(function(){
        var selected_offer_ids = seleted_offer_ids();
        console.log('selected ids' + selected_offer_ids);
        if(selected_offer_ids.length > 0){
            $.ajax({
                type: 'put',
                url: '/offers/toggle_star',
                dataType: "script",
                data: {ids: selected_offer_ids, 'authenticity_token': $('meta[name="csrf-token"]').attr('content')},
                success: function(data) {
                    console.log(data)
                }
            });
        }else{
            alert('At least one offer has to be selected');
        }

        return false;
    });

    function seleted_offer_ids(){
        var ids = [];
        $('.select-offer:checkbox:checked').each(function(){
            ids.push($(this).data('id'));
        });

        return jQuery.unique(ids);
    }
//    ======================= Offer controller javascript
//    control collapsing offer in offer index page
    $(document).on('click', '.offer-header', function(e) {

        e.preventDefault();
        var $offerBOx = $(this).parent();

        if( $offerBOx.find('.offer-body.in').length ){
            // already read all messages
        }else{
            //    make all message read to this message thread
            makeMessageRead($offerBOx.data('id'));
        }
        var $collapse = $offerBOx.find('.collapse');
        $collapse.collapse('toggle');
    });

    //prevent checkbox from event propagation for tab pan collapse
    $(document).on('click', '.select-offer', function(e){
        e.stopPropagation();
    });

//    reply message feature
    $(document).on('click', '.message-reply-button', function(e){
        var body = $(this).prev('.message-body').val();
        var offer_id = $(this).data('offer-id');
        var receiver_id = $(this).data('receiver-id');

        if(body.length > 0){
            $.ajax({
                type: 'post',
                url: '/offers/' + offer_id +'/reply_message',
                dataType: 'json',
                data: {'authenticity_token': $('meta[name="csrf-token"]').attr('content'), id: offer_id, receiver_id: receiver_id, body: body },
                success: function(data) {
                    if(data.success){
                        console.log(data);
                        $('.offer-textarea-' + data.id).val('');
                        console.log($('.offer-textarea-' + data.id));
                    }else{
                        alert('Some error have been  occur');
                    }

                }
            });
        }else{
            alert('Message body must be present ');
        }

    });

//    make all message read
    function makeMessageRead(campainId){
        if (campainId === undefined || campainId === null) {
            //no campaign id passed
        }else{
            $.ajax({
                type: 'post',
                url: '/offers/' + campainId +'/make_messages_read',
                dataType: 'json',
                data: {'authenticity_token': $('meta[name="csrf-token"]').attr('content')},
                success: function(data) {
                        $('.read-status-' + data.id).addClass('invisible');
                }
            });
        }
    }

//    delete selected offers
    $('.delete-selected-offer').click(function(){
        var selected_offer_ids = seleted_offer_ids();
        console.log('selected ids' + selected_offer_ids);
        if(selected_offer_ids.length > 0){
            $.ajax({
                type: 'put',
                url: '/offers/delete_offers',
                dataType: "script",
                data: {ids: selected_offer_ids, 'authenticity_token': $('meta[name="csrf-token"]').attr('content')},
                success: function(data) {
                    console.log(data)
                }
            });
        }else{
            alert('At least one offer has to be selected');
        }

        return false;
    });

//    withdraw request send  by influencer

    $('#btn-amount-withdraw').click(function(){
        var BankAccountId = $('input[name="bank_account"]:checked').val();
        var withdrawAmmount =  parseInt($('input#withdraw_amount').val());
        if(BankAccountId === undefined || BankAccountId === null || isNaN(withdrawAmmount)){
            alert('Select Bank account or give withdraw amount first ');
        }else{
            $.ajax({
                type: 'post',
                url: '/payments/withdraw',
                dataType: "script",
                data: {amount: withdrawAmmount, bank_account_id: BankAccountId, 'authenticity_token': $('meta[name="csrf-token"]').attr('content')},
                success: function(data) {
                    console.log(data)
                }
            });
        }
        return false;
    });

//    make hand burger button active
    $('.sidebar-toggle').click(function () {
        $('.skin-blue.sidebar-mini').toggleClass('sidebar-open');
    });

//     ajax sing up
        $("form#ajax_signup").submit(function(e){
            e.preventDefault(); //This prevents the form from submitting normally
            var user_info = $(this).serializeObject();
            console.log("About to post to /users: " + JSON.stringify(user_info));
            $.ajax({
                type: "POST",
                url: "http://localhost:3000/users",
                data: user_info,
                success: function(json){
                    console.log("The Devise Response: " + JSON.stringify(json));
                    //alert("The Devise Response: " + JSON.stringify(json));
                },
                dataType: "json"
            });
        });

    // ajax sign in
    var value = $("input[name='sign-in-role']:checked").val();

    showSignUpInfo(value);

    $("input[name='sign-in-role']").change(function () {
        var value = $("input[name='sign-in-role']:checked").val();
        console.log('selected user type is ' + value);
        showSignUpInfo(value);
    });

    function showSignUpInfo(id){
        if (id == '1') {
            $('#brand-signin').addClass('hidden');
            $('#influencer-signin').removeClass('hidden');
        } else {
            $('#brand-signin').removeClass('hidden');
            $('#influencer-signin').addClass('hidden');
        }
    }

    $('.navbar-header button').click(function() {
        if ($("#myNavbar.in").length)
        {
            $("#myNavbar").collapse('hide');
        }
        else
        {
            $("#myNavbar").collapse('show');
        }
    });

/*    show spinner button on form submit. To enable sinner for form submit
      add 'has-spinner' class to submit button and
      <span class="spinner"><i class="fa fa-spinner fa-spin"></i></span>
      with in button tag.

      Ex. <button class="btn btn-modal-submit has-spinner" type="submit">
            <span class="spinner"><i class="fa fa-spinner fa-spin"></i></span>
            SUBMIT
           </button>
 */
    //$('.show-spinner-on-submit').submit(function() {
    //    console.log('Form with spinner functionality has been submitted');
    //    $(this).find('.has-spinner').addClass('active');
    //});


});
// end of document.ready() method

function makeMessageRead(campainId){

    if (campainId === undefined || campainId === null) {
        //no campaign id passed
    }else{
        $.ajax({
            type: 'post',
            url: '/offers/' + campainId +'/make_messages_read',
            dataType: 'json',
            data: {'authenticity_token': $('meta[name="csrf-token"]').attr('content')},
            success: function(data) {
                $('.read-status-' + data.id).addClass('invisible');
            }
        });
    }

}

