FROM quay.io/keycloak/keycloak:26.7.1

LABEL org.opencontainers.image.source="https://github.com/reesing322/soccerproject-keycloak-theme"

COPY --chown=keycloak:keycloak themes/soccerproject /opt/keycloak/themes/soccerproject
