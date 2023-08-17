package completion

import (
	"log"
	"strings"

	"github.com/hashicorp/terraform-config-inspect/tfconfig"
)

func GetCompletionItems(searchString string, dir string, inRootModule bool, localModuleName string) []string {
	var completionItems []string = make([]string, 0)

	module, diags := tfconfig.LoadModule(dir)
	if diags.HasErrors() {
		log.Fatalf("Error loading module: %s", diags.Err())
	}

	for _, resource := range module.ManagedResources {
		var resourceTypeAndName string = resource.MapKey()
		var resourceFullPathName string = resourceTypeAndName

		if !inRootModule {
			resourceFullPathName = localModuleName + "." + resourceTypeAndName
		}

		if !strings.HasPrefix(resourceFullPathName, searchString) {
			continue
		}

		completionItems = append(completionItems, resourceFullPathName)
	}

	for _, moduleCall := range module.ModuleCalls {
		var foundModuleSimpleName string = moduleCall.Name

		var foundModuleName string = localModuleName + ".module." + foundModuleSimpleName
		if inRootModule {
			foundModuleName = "module." + foundModuleSimpleName
		}

		var foundModuleDir string = moduleCall.Source

		if !inRootModule {
			foundModuleDir = dir + "/" + foundModuleDir
		}

		if !strings.HasPrefix(foundModuleName, searchString) {
			continue
		}

		completionItems = append(completionItems, foundModuleName)

		// If the module is not a module directory, skip it (don't go into it), i.e., we do not support modules source coming from a URL
		// such as "module "vault_cluster" { source = "git::https://git::https://gitlab.whavewave.net/shellwhale/vault_cluster.git
		// instead of "module "vault_cluster" { source = "./modules/vault_cluster"
		if !tfconfig.IsModuleDir(foundModuleDir) {
			continue
		}

		var recursiveCompletionList []string = GetCompletionItems(searchString, foundModuleDir, false, foundModuleName)

		for _, item := range recursiveCompletionList {
			if !strings.HasPrefix(item, searchString) {
				continue
			}

			completionItems = append(completionItems, item)
		}

	}

	return completionItems
}
