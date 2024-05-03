ad_query() {
    source $HOME/dotfiles/.key.env.sh    
    # LDAP_URL=''
    # SEARCH_USER=''
    # SEARCH_PW='''
    # SEARCH_OU=''

    FILTER=$1
    GET="displayName::"
 
    if [ $( echo $FILTER | grep "^[1-9]" | wc -l ) -eq 1 ] ; then
        FNAME="(cn=${FILTER}*)"
    else
        FNAME="(displayName=${FILTER}*)"
    fi

    ldapsearch -x -H ${LDAP_URL} -b "${SEARCH_OU}" -s sub -D "${SEARCH_USER}" -w "${SEARCH_PW}" "${FNAME}" | perl -p0e 's/\n //g' > /tmp/ad_query

#    echo 'ldapsearch -x -H ${LDAP_URL} -b "${SEARCH_OU}" -s sub -D "${SEARCH_USER}" -w "${SEARCH_PW}" "${FNAME}" | perl -p0e 's/\n //g' > /tmp/ad_query'
    if [ $( grep '^employeeID' /tmp/ad_query | wc -l ) -eq 0 ] ; then
        DN=$(grep '^dn::' /tmp/ad_query | head -1 | awk '{ print $2 }' | base64 --decode )
        INFO=$( echo "INFO="$( grep '^member:' /tmp/ad_query | awk -F\= '{ print $2 }' | awk -F, '{ print $1 }' ) | sed 's/ /,/g' )
    else
        DN=$( grep "^$GET" /tmp/ad_query | head -1 | awk '{ print $2 }' | base64 --decode )
        ID=$( grep '^employeeID' /tmp/ad_query | head -1 | awk '{ print $2 }' )
        TEL=$( grep '^telephoneNumber' /tmp/ad_query | awk '{ print $2}' )
        MAIL=$( grep '^mail:' /tmp/ad_query | awk '{ print $2}' )
        PHONE=$( grep '^mobile:' /tmp/ad_query | awk '{ print $2}' )
        INFO=$(echo "INFO="${ID},${TEL},${PHONE},${MAIL})
    fi
    echo "$DN  ($INFO)"
}
