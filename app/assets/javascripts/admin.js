/**
 * Created by sumon on 12/8/15.
 */

$(function () {
    /* ====== deactivate active user ==============*/
    $('.activate-user').click(function () {
        var userId = $(this).data('id');

        bootbox.confirm({
            message: 'Do you really want to activate this user?',
            closeButton: false,
            callback: function (result) {
                if (result) {
                    $.ajax({
                        type: 'put',
                        url: '/admins/' + userId + '/activate_user',
                        dataType: "script",
                        data: {
                            'authenticity_token': $('meta[name="csrf-token"]').attr('content')
                        },
                        success: function (data) {
                            console.log(data)
                        }
                    });
                }
            }
        });
    });

    /* ====== deactivate active user ==============*/
    $('.deactivate-user').click(function () {
        var userId = $(this).data('id');

        bootbox.confirm({
            message: "Do you really want to deactivate this user?",
            closeButton: false,
            callback: function (result) {
                if (result) {
                    $.ajax({
                        type: 'put',
                        url: '/admins/' + userId + '/deactivate_user',
                        dataType: "script",
                        data: {
                            'authenticity_token': $('meta[name="csrf-token"]').attr('content')
                        },
                        success: function (data) {
                            console.log(data)
                        }
                    });
                }
            }
        });
    });


    $('.remove-admin').click(function () {
        var adminId = $(this).data('id');

        bootbox.confirm({
            message: 'Do you really want to remove this admin?',
            closeButton: false,
            callback: function (result) {
                if (result) {
                    $.ajax({
                        type: 'delete',
                        url: '/admins/' + adminId,
                        dataType: "script",
                        data: {
                            'authenticity_token': $('meta[name="csrf-token"]').attr('content')
                        },
                        success: function (data) {
                            console.log(data)
                        }
                    });
                }
            }
        });
    });
});
