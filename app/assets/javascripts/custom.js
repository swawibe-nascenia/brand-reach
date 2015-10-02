/**
 * Created by sumon on 10/2/15.
 */
$(function(){


//    toggle star of selected offers
    $('.make-all-stared').click(function(){
        var selected_offer_ids = seleted_offer_ids();
        console.log('selected ids' + selected_offer_ids);
        $.ajax({
            type: 'put',
            url: '/offers/toggle_star',
            dataType: "script",
            data: {ids: selected_offer_ids, 'authenticity_token': $('meta[name="csrf-token"]').attr('content')},
            success: function(data) {
                console.log(data)
            }
        });

    });

    function seleted_offer_ids(){
        var ids = [];
        $('.select-offer:checkbox:checked').each(function(){
            ids.push($(this).data('id'));
        });

        return jQuery.unique(ids);
    }

});

