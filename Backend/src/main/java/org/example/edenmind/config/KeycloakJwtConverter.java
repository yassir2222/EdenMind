package org.example.edenmind.config;

import org.springframework.core.convert.converter.Converter;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;

import java.util.Collection;
import java.util.Collections;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class KeycloakJwtConverter implements Converter<Jwt, AbstractAuthenticationToken> {

    private final JwtGrantedAuthoritiesConverter defaultGrantedAuthoritiesConverter = new JwtGrantedAuthoritiesConverter();

    @Override
    public AbstractAuthenticationToken convert(Jwt jwt) {
        Collection<GrantedAuthority> authorities = Stream.concat(
                defaultGrantedAuthoritiesConverter.convert(jwt).stream(),
                extractResourceRoles(jwt).stream()
        ).collect(Collectors.toSet());

        return new JwtAuthenticationToken(jwt, authorities, jwt.getClaimAsString("preferred_username"));
    }

    @SuppressWarnings("unchecked")
    private Collection<GrantedAuthority> extractResourceRoles(Jwt jwt) {
        Map<String, Object> realmAccess = jwt.getClaim("realm_access");

        if (realmAccess == null || realmAccess.get("roles") == null) {
            return Collections.emptySet();
        }

        Collection<String> roles = (Collection<String>) realmAccess.get("roles");

        return roles.stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role.toUpperCase()))
                .collect(Collectors.toSet());
    }
}