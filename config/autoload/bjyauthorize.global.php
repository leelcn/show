<?php

return [
    'bjyauthorize' => [

        // set the 'guest' role as default (must be defined in a role provider)
        'default_role' => 'guest',

        /* this module uses a meta-role that inherits from any roles that should
         * be applied to the active user. the identity provider tells us which
         * roles the "identity role" should inherit from.
         *
         * for ZfcUser, this will be your default identity provider
         */
        'identity_provider' => 'BjyAuthorize\Provider\Identity\AuthenticationIdentityProvider',

        /* role providers simply provide a list of roles that should be inserted
         * into the Zend\Acl instance. the module comes with two providers, one
         * to specify roles in a config file and one to load roles using a
         * Zend\Db adapter.
         */
        'role_providers' => [

            'BjyAuthorize\Provider\Role\Config' => [
                'guest' => [],
                'admin' => [],
                'callcenter' => [],
                'user' => [],
            ],
        ],

    ],

    // resource providers provide a list of resources that will be tracked
    // in the ACL. like roles, they can be hierarchical
    'resource_providers' => [],

    /* rules can be specified here with the format:
     * array(roles (array), resource, [privilege (array|string), assertion])
     * assertions will be loaded using the service manager and must implement
     * Zend\Acl\Assertion\AssertionInterface.
     * *if you use assertions, define them using the service manager!*
     */
    'rule_providers' => [],

    /* Currently, only controller and route guards exist
     *
     * Consider enabling either the controller or the route guard depending on your needs.
     */
    'guards' => [],

    'unauthorized_strategy' => 'BjyAuthorize\View\RedirectionStrategy',
];
