/**
 * Created by sumon on 12/8/15.
 */

$(function(){
/* ====== deactivate active user ==============*/
    $('.activate-user').click(function(){
        if(confirm('Do you really want to active this user?')){
            var userId = $(this).data('id');

            $.ajax({
                type: 'put',
                url: '/admins/' +  userId + '/activate_user',
                dataType: "script",
                data: {
                    'authenticity_token': $('meta[name="csrf-token"]').attr('content')
                },
                success: function(data) {
                    console.log(data)
                }
            });
        }
    });

/* ====== deactivate active user ==============*/
    $('.deactivate-user').click(function(){
        if(confirm('Do you really want to remove this user?')){
            var userId = $(this).data('id');

            $.ajax({
                type: 'put',
                url: '/admins/' +  userId + '/deactivate_user',
                dataType: "script",
                data: {
                    'authenticity_token': $('meta[name="csrf-token"]').attr('content')
                },
                success: function(data) {
                    console.log(data)
                }
            });
        }
    });
});
