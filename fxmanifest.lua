fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'Asraye'
description 'Basic drug system for FadedNetworks'

shared_scripts {
    'config/cfg_main.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'client/cl_*.lua' 
}

server_scripts {
    'server/sv_*.lua'
}