{#

OPNsense® is Copyright © 2014 – 2020 by Deciso B.V.
This file is Copyright © 2020 by Michael Muenz <m.muenz@gmail.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

#}

<!-- Navigation bar -->
<ul class="nav nav-tabs" data-tabs="tabs" id="maintabs">
    <li class="active"><a data-toggle="tab" href="#general">{{ lang._('General') }}</a></li>
    <li><a data-toggle="tab" href="#staticmappings">{{ lang._('Static Mappings') }}</a></li>
</ul>

<div class="tab-content content-box">
    <div class="tab-pane fade in active" id="general" style="padding-bottom: 1.5em;">
        {{ partial("layout_partials/base_form",['fields':generalForm,'id':'frm_general_settings'])}}
        <div class="col-md-12">
            <hr />
            <button class="btn btn-primary" id="saveAct" type="button"><b>{{ lang._('Save') }}</b> <i id="saveAct_progress"></i></button>
        </div>
    </div>
    <div id="staticmappings" class="tab-pane fade in">
        <div id="staticmappings-area" class="table-responsive">
            <table id="grid-staticmappings" class="table table-condensed table-hover table-striped" data-editDialog="dialogEditStaticMapping">
                <thead>
                    <tr>
                        <th data-column-id="enabled" data-type="string" data-formatter="rowtoggle">{{ lang._('Enabled') }}</th>
                        <th data-column-id="v4" data-type="string" data-visible="true" data-css-class="long-str">{{ lang._('IPv4 Network') }}</th>
                        <th data-column-id="v6" data-type="string" data-visible="true" data-css-class="long-str">{{ lang._('IPv6 Network') }}</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan="5"></td>
                        <td>
                            <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                            <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
        <div class="col-md-12">
            <hr />
            <button class="btn btn-primary" id="saveAct_staticmapping" type="button"><b>{{ lang._('Save') }}</b> <i id="saveAct_staticmapping_progress"></i></button>
            <br /><br />
        </div>
    </div>
</div>
{{ partial("layout_partials/base_dialog",['fields':formDialogEditStaticMapping,'id':'dialogEditStaticMapping','label':lang._('Edit mapping')])}}

<script>
    $( document ).ready(function() {
        var data_get_map = {'frm_general_settings':"/api/tayga/general/get"};
        mapDataToFormUI(data_get_map).done(function(data){
            formatTokenizersUI();
            $('.selectpicker').selectpicker('refresh');
        });
        ajaxCall(url="/api/tayga/service/status", sendData={}, callback=function(data,status) {
            updateServiceStatusUI(data['status']);
        });

        // link save button to API set action
        $("#saveAct").click(function(){
            saveFormToEndpoint(url="/api/tayga/general/set", formid='frm_general_settings',callback_ok=function(){
                    $("#saveAct_progress").addClass("fa fa-spinner fa-pulse");
                    ajaxCall(url="/api/tayga/service/reconfigure", sendData={}, callback=function(data,status) {
                            ajaxCall(url="/api/tayga/service/status", sendData={}, callback=function(data,status) {
                                    updateServiceStatusUI(data['status']);
                            });
                            $("#saveAct_progress").removeClass("fa fa-spinner fa-pulse");
                    });
            });
        });

        $("#grid-staticmappings").UIBootgrid({
            'search': '/api/tayga/mapping/search_staticmapping',
            'get': '/api/tayga/mapping/get_staticmapping/',
            'set': '/api/tayga/mapping/set_staticmapping/',
            'add': '/api/tayga/mapping/add_staticmapping/',
            'del': '/api/tayga/mapping/del_staticmapping/',
            'toggle': '/api/tayga/mapping/toggle_staticmapping/'
        });
        $("#saveAct_staticmapping").click(function() {
            saveFormToEndpoint(url = "/api/tayga/mapping/set", formid = 'frm_general_settings', callback_ok = function() {
                $("#saveAct_staticmapping_progress").addClass("fa fa-spinner fa-pulse");
                ajaxCall(url = "/api/tayga/service/reconfigure", sendData = {}, callback = function(data, status) {
                    updateServiceControlUI('tayga');
                    $("#saveAct_staticmapping_progress").removeClass("fa fa-spinner fa-pulse");
                });
            });
        });
    });
</script>
