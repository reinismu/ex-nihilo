#  EX-NIHILO

Learning project. Aim is to get better understanding of various DevOps tools and learn kubernetes.


## Notes

## Deployment
As we are using terraform and it is not best tool for software you will need to do following steps to create custer:
 * Comment out `kubernetes` module and do initial server run
 * It will fail first time. Run again and it will work fine (could be some ssh firewall issues)
 * Uncomment `kubernetes` module and apply again.

## Unresolved issues

 * Scaleway could-init is 50/50 so have to do firewall config again
 * DNS doesn't want to work as it should.
 * Terraform race condition (aka. cant build whole thing in one run)
