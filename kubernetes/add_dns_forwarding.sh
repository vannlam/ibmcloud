#oc get -n kube-system configmap coredns -o yaml curr_coredns.yaml
awk -v subdomain=$1 -v ip=$2 '
function add_forward(subdom, ip) { 
        printf "   %s:53 {",subdom
        print "      errors"
        print "      cache 30"
        printf "      forward . %s",ip
        print "    }"
}
BEGIN { ins=0 }
{
        if (match($0,"data:")==1) { ins=1 }
        if ((match($0,"[a-z]")==1) && (ins==1)) {
                add_forward(subdomain, ip)
                ins=0
        }
        print
}
END {
        if (ins==1) { add_forward(subdomain, ip) }
}' curr_coredns.yaml > coredns.yaml
