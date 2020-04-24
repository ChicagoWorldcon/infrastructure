{
    email ${admin_email}
%{ if test_cert }
    acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
%{ endif }
}

${www_domain_name} {
    log stdout
%{ if stage != "prod" }
    basicauth / {
        preview JDJhJDEwJEJsRlZCSEwwVjFMSTdJWmF5cDNSUS5FTFk3M2VERFBEaVRSYVFjd0R6Yldwdy93Y0VKZ0Jh
    }
%{ endif }
    reverse_proxy * web:3000 {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Port {server_port}
        header_up X-Forwarded-Proto {scheme}
    }
}

${sidekiq_domain_name} {
    log stdout

    reverse_proxy * worker:36465 {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Port {server_port}
        header_up X-Forwarded-Proto {scheme}
    }
}


