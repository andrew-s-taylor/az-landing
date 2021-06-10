//Create Policy to restrict SKUs

targetScope = 'subscription'

param listOfAllowedLocations array = [
  'uksouth'
  'ukwest'
  'northeurope'
  'westeurope'
]

param listOfAllowedSKUs array = [
  'Standard_B1ls'
  'Standard_B1ms'
  'Standard_B1s'
  'Standard_B2ms'
  'Standard_B2s'
  'Standard_B4ms'
  'Standard_B4s'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
]
param tagname string
param tagvalue string


var initiativeDefinitionName = 'SKU and Location Policy'

resource initiativeDefinition 'Microsoft.Authorization/policySetDefinitions@2019-09-01' = {
  name: initiativeDefinitionName
  properties: {
    policyType: 'Custom'
    displayName: initiativeDefinitionName
    description: 'Initiative Definition for Resource Location and VM SKUs'
    metadata: {
      category: 'SKU and Location Policy'
    }
    parameters: {
      listOfAllowedLocations: {
        type: 'Array'
        metadata: ({
          description: 'The List of Allowed Locations for Resource Groups and Resources.'
          strongtype: 'location'
          displayName: 'Allowed Locations'
        })
      }
      listOfAllowedSKUs: {
        type: 'Array'
        metadata: any({
          description: 'The List of Allowed SKUs for Virtual Machines.'
          strongtype: 'vmSKUs'
          displayName: 'Allowed Virtual Machine Size SKUs'
        })
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988'
        parameters: {
          listOfAllowedLocations: {
            value: '[parameters(\'listOfAllowedLocations\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
        parameters: {
          listOfAllowedLocations: {
            value: '[parameters(\'listOfAllowedLocations\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3'
        parameters: {
          listOfAllowedSKUs: {
            value: '[parameters(\'listOfAllowedSKUs\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0015ea4d-51ff-4ce3-8d8c-f3f8f0179a56'
        parameters: {}
      }
    ]
  }
}

resource initiativeDefinitionPolicyAssignment 'Microsoft.Authorization/policyAssignments@2019-09-01' = {
  name: initiativeDefinitionName
  properties: {
    scope: subscription().id
    enforcementMode: 'Default'
    policyDefinitionId: initiativeDefinition.id
    parameters: {
      listOfAllowedLocations: {
        value: listOfAllowedLocations
      }
      listOfAllowedSKUs: {
        value: listOfAllowedSKUs
      }
    }
  }
}

//Create Policy to require tag


resource tagpolicydef 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: 'audit-tags'
  properties: {
    displayName: 'Audit a tag and its value format on resources'
    description: 'Audits existence of a tag and its value format. Does not apply to resource groups.'
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      category: 'Tags'
    }

    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: tagname
          description: 'A tag to audit'
        }
      }
      tagFormat: {
        type: 'String'
        metadata: {
          displayName: tagvalue
          description: 'An expressions for \'like\' condition' // Use backslash as an escape character for single quotation marks
        }
      }
    }

    policyRule: {
      if: {
        field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]' // No need to use an additional forward square bracket in the expressions as in ARM templates
        notLike: '[parameters(\'tagFormat\')]'
      }
      then: {
        effect: 'Audit'
      }
    }
  }
}


resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'deny-without-tags' //Should be unique whithin your target scope
  properties: {
    policyDefinitionId: tagpolicydef.id // Reference a policy specified in the same Bicep file
    displayName: 'Deny anything without the \'tag_name\' on resources'
    description: 'Policy will Deny resources not tagged with a specific tag'
    parameters: {
      tagName: {
        value: 'tag_name'
      }
    }
  }
}


//Create Policy to block public IPs

resource blockpublicip 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: 'blockpublicip'
  properties: {
    displayName: 'Block Public IP'
    description: 'Block network interface from having a public IP'
    policyType: 'Custom'
    mode: 'Indexed'
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Network/networkInterface'
          }
         {
            field: 'Microsoft.Network/networkInterfaces/ipconfigurations[*].publicIpAddress.id'
            notlike: '*'
          
          }

        ]
      }
      then: {
        effect: 'Audit'
      }
    }
  }
}

resource blocktheip 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'block-public-ip' //Should be unique whithin your target scope
  properties: {
    policyDefinitionId: blockpublicip.id // Reference a policy specified in the same Bicep file
    displayName: 'Audit Public IP'
    description: 'Policy block public IP on network interfaces - Audit Only during build'
    parameters: { }
    }
  }
