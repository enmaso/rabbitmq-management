%%   The contents of this file are subject to the Mozilla Public License
%%   Version 1.1 (the "License"); you may not use this file except in
%%   compliance with the License. You may obtain a copy of the License at
%%   http://www.mozilla.org/MPL/
%%
%%   Software distributed under the License is distributed on an "AS IS"
%%   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
%%   License for the specific language governing rights and limitations
%%   under the License.
%%
%%   The Original Code is RabbitMQ Management Plugin.
%%
%%   The Initial Developer of the Original Code is GoPivotal, Inc.
%%   Copyright (c) 2007-2016 Pivotal Software, Inc.  All rights reserved.
%%

-module(rabbit_mgmt_wm_topic_permissions).

-export([init/3, rest_init/2, to_json/2, content_types_provided/2, is_authorized/2]).
-export([topic_permissions/0]).
-export([variances/2]).

-include_lib("rabbitmq_management_agent/include/rabbit_mgmt_records.hrl").
-include_lib("rabbit_common/include/rabbit.hrl").

%%--------------------------------------------------------------------

init(_, _, _) -> {upgrade, protocol, cowboy_rest}.

rest_init(Req, _Config) ->
    {ok, rabbit_mgmt_cors:set_headers(Req, ?MODULE), #context{}}.

variances(Req, Context) ->
    {[<<"accept-encoding">>, <<"origin">>], Req, Context}.

content_types_provided(ReqData, Context) ->
   {[{<<"application/json">>, to_json}], ReqData, Context}.

to_json(ReqData, Context) ->
    rabbit_mgmt_util:reply_list(topic_permissions(), ["vhost", "user"],
                                ReqData, Context).

is_authorized(ReqData, Context) ->
    rabbit_mgmt_util:is_authorized_admin(ReqData, Context).

%%--------------------------------------------------------------------

topic_permissions() ->
    List = rabbit_auth_backend_internal:list_topic_permissions(),
    List.
