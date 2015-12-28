/**
 * Created by sumon on 10/2/15.
 */
$(function(){

//    ======================== handlebar helper method add ======================
    Handlebars.registerHelper ('truncate', function (str, len) {
        if (str && str.length > len && str.length > 0) {
            var new_str = str + " ";
            new_str = str.substr (0, len);
            new_str = str.substr (0, new_str.lastIndexOf(" "));
            new_str = (new_str.length > 0) ? new_str : str.substr (0, len);

            return new Handlebars.SafeString ( new_str +'...' );
        }
        return str;
    });

//    toggle star of selected offers
    $('.make-all-stared').click(function(){
        if($(this).hasClass('disable')){
            // there is no offer now
            return false;
        }

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
            bootbox.alert({message: 'At least one offer has to be selected', closeButton: false});
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
        if (e.toElement && e.toElement.classList.contains('btn')) {
            return true;
        }

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

    //prevent checkbox from event propagation for tab pan collapse
    $(document).on('click', '.btn.engage', function(e){
        e.stopPropagation();
    });

//    reply message feature
    $(document).on('click', '.message-reply-button', function(e){
        var offer_id = $(this).data('offer-id');
        console.log('current offer id is ' + offer_id);
        var body =  $.trim($('#offer-textarea-' + offer_id ).val());
        var receiver_id = $(this).data('receiver-id');
        var attach_iamge_ids = $('#attach_image_ids-' + offer_id).val();

        if(body.length > 0){
            $.ajax({
                type: 'post',
                url: '/offers/' + offer_id +'/reply_message',
                dataType: 'json',
                data: {'authenticity_token': $('meta[name="csrf-token"]').attr('content'),
                        id: offer_id, receiver_id: receiver_id, body: body,
                        attach_iamge_ids: attach_iamge_ids },
                success: function(data) {
                    if(data.success){
                        console.log(data);
                        $('#offer-textarea-' + data.id).val('');
                        $('#image-proview-container-' + data.id).html(' ');
                        console.log($('.offer-textarea-' + data.id));
                    }else{
                        bootbox.alert({message: 'Some error have been  occur.',
                            closeButton: false});

                    }

                }
            });
        }else{
            bootbox.alert({message: 'Message body must be present.',
                closeButton: false});
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
                    if(parseInt(data.unreadMessages) > 0){
                        console.log('----------------We have unread message------------- ');
                        $('span.unread-message').html("(<span class='unread-message-number'>" + data.unreadMessages + "</span>)");
                    }else{
                        console.log('----------------We have no unread message------------- ');
                        $('span.unread-message').html('');
                    }
                }
            });
        }
    }

//    delete selected offers
    $('.delete-selected-offer').click(function(){
        if($(this).hasClass('disable')){
            // there is no offer now
            return false;
        }

        var selected_offer_ids = seleted_offer_ids();
            console.log('selected ids' + selected_offer_ids);
            if(selected_offer_ids.length > 0){
                bootbox.confirm({
                    message: "Are you sure you want to delete the Campaign?",
                    closeButton: false,
                    callback: function(result) {
                        if(result){
                            $.ajax({
                                type: 'put',
                                url: '/offers/delete_offers',
                                dataType: "script",
                                data: {ids: selected_offer_ids, 'authenticity_token': $('meta[name="csrf-token"]').attr('content')},
                                success: function(data) {
                                    console.log(data)
                                }
                            });
                        }
                    }
                });

            }else{
                bootbox.alert({message: 'At least one offer has to be selected',
                                closeButton: false});
            }


        return false;
    });

//    withdraw request send  by influencer

    $('#btn-amount-withdraw').click(function(){
        var BankAccountId = $('input[name="bank_account"]:checked').val();
        var withdrawAmmount =  parseInt($('input#withdraw_amount').val());
        if(BankAccountId === undefined || BankAccountId === null || isNaN(withdrawAmmount)){
            bootbox.alert({message: 'Select Bank account or give withdraw amount first ',
                closeButton: false});
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

/* =============== profile picture crop modal show ================= */
    $('.profile-image.present').click(function(){
        $('#profile_image_edit_modal').modal('show');
        var windowWidth = $(window).width();

        console.log('current window width is ' + windowWidth);

        if(windowWidth > 500){
            windowWidth = 500;
        }else{
            windowWidth = windowWidth - 100;
        }

        var imageWidth = $('#profile-pic-edit').width();
        if(imageWidth > windowWidth){
            imageWidth = windowWidth;
        }

        $('#profile_image_edit_modal .modal-footer').width(imageWidth + '');

    });

/* ====================loading image show for insight page load ====================*/
    $('.load-page').click(function(){
        $('.loader').show();
    });

/* ==================== advance search functionality ==============*/
    $('#explore-category').change(function(){
        console.log('filter influencer with their category....');
        makeAdvanceSearch();
    });

    $('#explore-social-media').change(function(){
        makeAdvanceSearch();
    });

    $('.brands-explore-advance-search #country').change(function(){
        var countryCode = $(this).val();
        var url = "/subregion_options?parent_region=" + countryCode;
        $('#explore-state').load(url, function(){
            console.log('Load is perform ');
            makeAdvanceSearch();
        });

    });

    $(document).on('change', '#explore-state #user_state', function(){
        makeAdvanceSearch();
    });

    $('#explore-price').change(function(){
        makeAdvanceSearch();
    });

    $('#explore-followers').change(function(){
        makeAdvanceSearch();
    });

   function makeAdvanceSearch(){
       var searchKey = $('#search-keyword').val();
       var category = $('#explore-category').val();
       var socialMedia = $('#explore-social-media').val();
       var country = $('#country').val();
       var state = $('#user_state').val();
       var price = $('#explore-price').val();
       var followers = $('#explore-followers').val();

       console.log('Current selected state code is ' + state);

       $.ajax({
           type: 'get',
           url: '/explore',
           dataType: "script",
           data: {
                search_key: searchKey,
                category: category,
                social_media: socialMedia,
                country: country,
                state: state,
                price: price,
                followers: followers,
                'authenticity_token': $('meta[name="csrf-token"]').attr('content')
           },
           success: function(data) {
               console.log(data)
           }
       });
   }

/* ========== reset advance search search item ================*/
    $('a.btn-reset').click(function(){
        resetAdvanceSearchInput();
        makeAdvanceSearch();
    });

    function resetAdvanceSearchInput(){
        $('#search-keyword').val('');
        $('#explore-category').val('');
        $('#explore-social-media').val('');
        $('#country').val('');
        $('#user_state').val('<input id="state" type="text" disabled="disabled" value="Select Country" name="state">');
        $('#explore-price').val('');
        $('#explore-followers').val('');
    }

    // fixed navigation

    setTopNav();
    $(document).scroll(function() {
        setTopNav();
    });

    function setTopNav(){
        var scrollTop = $(document).scrollTop();
        var offsetTop = $('.welcome_bar').outerHeight();

        var windowWidth = $( window ).width();
        if (scrollTop > offsetTop && windowWidth > 767) {
            $('.header').css('top', 0);
        } else {
            $('.header').css('top', offsetTop - scrollTop);
        }
    }

    /* new add for modal my pc only */
    $('#signup').on('show.bs.modal', function (e) {
        $('body').addClass('test');
    });

    /*======== jquery image upload ================*/
    $('.add_image').fileupload({
        dataType: "script",
        add: function (e, data) {
            var vals = Object.keys(data).map(function(key){
                return data[key];
            });

            var file, types;
            types = /(\.|\/)(gif|jpe?g|png)$/i;
            file = data.files[0];
            if (types.test(file.type) || types.test(file.name)) {
                $('#loading-indicator').show();
                return data.submit();
            } else {
                return alert("" + file.name + " is not a valid format!");
            }
        },
        progress: function (e, data) {
            var progress;
            if (data.context) {
                progress = parseInt(data.loaded / data.total * 100, 10);
                return data.context.find('.bar').css('width', progress + '%');
            }
        },
        stop: function (e, data) {
            $('.upload').hide();
            $('#loading-indicator').hide();
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

    // remove '#_=_' from URL after being redirected from Facebook authentication
    if (window.location.hash == '#_=_') {
        history.replaceState({}, '', window.location.href.slice(0, -4));
    }

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

/*================ Update side bar unread message counter ================*/
function updateUnreadMessage(){
    var presentUnreadMessages = parseInt($('span.unread-message-number').text());
    console.log('current unread message ' + presentUnreadMessages );

    if(isNaN(presentUnreadMessages)){
        console.log('this is not a number');
        $('span.unread-message').html("(<span class='unread-message-number'>" + 1 + "</span>)");
    }else{
        presentUnreadMessages += 1;
            $('span.unread-message-number').text(presentUnreadMessages);
    }
}

// custom window width with custom calculation
function getWindoWidth(){
    var windowWidth = $(window).width();
    console.log('current window width is ' + windowWidth);
    if(windowWidth > 500){
        windowWidth = 500;
    }else{
        windowWidth = windowWidth - 100;
    }
    return windowWidth;
}

/*====  set modal dialog max width ============*/
function setModalMaxWidthImageCrop($obj, imageWidth, minWidth){
    var modalDialogMaxWidth = 0;
    if((imageWidth + 108) > minWidth){
        modalDialogMaxWidth = imageWidth + 108;
        if(modalDialogMaxWidth > 608){
            modalDialogMaxWidth = 608;
        }
    }else{
        modalDialogMaxWidth = minWidth;
    }
    console.log('Set modal dialog max width to ' + modalDialogMaxWidth);
    $obj.css('max-width',  modalDialogMaxWidth);
}


/* =========================== function for disable offer delete and start icon =============== */
function disableOfferDeleteStartIcon(){
    console.log('disabling star and delete icon');
    $('.delete-selected-offer').addClass('disable');
    $('.make-all-stared').addClass('disable');
}

/*  ========== message for operation on already deleted offer ================*/
function unsuccessfulOfferOperationNotice(offer_id, message){
    console.log('===============Your offer already deleted==========');
    console.log(message);
    $('.offer-box-' + offer_id).remove();
}

/*========= message and campaign image upload event bind =====*/
function bindFileUpload(offer){
console.log('bind fileupload event for ' + offer );
    offer.find('.addImage').click(function(){
        console.log('add image button click' + $(this).data('id'));
        $('#upload-message-image-' + $(this).data('id')).click();
//        $(this).closest('.upload-message-image').click();
    });

    offer.find('.add_image').fileupload({
        dataType: "script",
        add: function (e, data) {
            var vals = Object.keys(data).map(function(key){
                return data[key];
            });

            var file, types;
            types = /(\.|\/)(gif|jpe?g|png)$/i;
            file = data.files[0];
            if (types.test(file.type) || types.test(file.name)) {
                $('#new_message_images').append(data.context);
                $('#image-loading-message').show();
                $('#loading-indicator').show();
                return data.submit();
            } else {
                return alert("" + file.name + " is not a valid format!");
            }
        },
        progress: function (e, data) {
            var progress;
            if (data.context) {
                progress = parseInt(data.loaded / data.total * 100, 10);
                return data.context.find('.bar').css('width', progress + '%');
            }
        },
        stop: function (e, data) {
            $('.upload').hide();
            $('#loading-indicator').hide();
            $('#image-loading-message').hide();

        }
    });

    addEnterKeyEvent(offer.find('.offer-textarea'));

}

/* ============== send message on enter key press ============*/
function addEnterKeyEvent($element){
    $element.keypress(function (e) {
        var key = e.which;
        if(key == 13)  // the enter key code
        {
            $(this).siblings('.message-reply-button').click();
            return false;
        }
    });
}
