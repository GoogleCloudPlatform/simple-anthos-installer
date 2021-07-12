package main

import (
	"errors"
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/stretchr/testify/assert"
)

func TestAnthosServiceMesh(t *testing.T) {
	t.Parallel()

	//Setup the kubectl config and context.
	options := k8s.NewKubectlOptions("", "", "default")

	// defer the removal of side car injection
	defer k8s.RunKubectlE(t, options, "label", "namespace", "default", "istio-injection-", "istio.io/rev-")

	enableSidecarProxyInjection(t)

	// Install the app
	kubeResourcePath := "../whareami-app/k8s"
	kubeResourcePath_backend := "../whareami-app/k8s-backend-overlay"
	kubeResourcePath_frontend := "../whareami-app/k8s-frontend-overlay"

	// first defer the deletion
	defer k8s.RunKubectlE(t, options, "delete", "-k", kubeResourcePath)
	defer k8s.RunKubectlE(t, options, "delete", "-k", kubeResourcePath_backend)
	defer k8s.RunKubectlE(t, options, "delete", "-k", kubeResourcePath_frontend)

	// Apply the app configs using kustomize for the whereami app https://github.com/GoogleCloudPlatform/kubernetes-engine-samples/tree/master/whereami
	k8s.RunKubectlE(t, options, "apply", "-k", kubeResourcePath)
	k8s.RunKubectlE(t, options, "apply", "-k", kubeResourcePath_backend)
	k8s.RunKubectlE(t, options, "apply", "-k", kubeResourcePath_frontend)

	k8s.WaitUntilServiceAvailable(t, options, "whereami-frontend", 50, 3*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "whereami-backend", 50, 3*time.Second)

	pod_count := retry.DoWithRetry(t, "Verify Sidecar proxy Injection", 50, 3*time.Second, func() (string, error) {

		// Ensure service envoy proxy sidecar is there
		get_pod_count := "kubectl -n default get pods -l app=whereami | grep whereami | awk '{print $2}' | sort -u"
		pod_count_cmd := shell.Command{
			Command: "bash",
			Args:    []string{"-c", get_pod_count},
		}
		pod_count := shell.RunCommandAndGetOutput(t, pod_count_cmd)
		if pod_count == "2/2" {
			return pod_count, nil
		}
		return "", errors.New("Retry")

	})

	assert.Equal(t, pod_count, "2/2")

	istio_options := k8s.NewKubectlOptions("", "", "istio-system")
	ingress := k8s.GetIngress(t, istio_options, "gke-ingress")
	assert.True(t, k8s.IsIngressAvailable(ingress), "Ingress not available")

	ingress_endpoint := ingress.Status.LoadBalancer.Ingress[0].IP

	if assert.NotEmpty(t, ingress_endpoint) {
		//service := k8s.GetService(t, options, "whereami-frontend")
		url := fmt.Sprintf("http://%s", ingress_endpoint)
		http_helper.HttpGetWithRetryWithCustomValidation(t, url, nil, 30, 1*time.Second, func(status int, body string) bool {
			assert.True(t, status == 200)
			assert.True()
		})
	}

}

func enableSidecarProxyInjection(t *testing.T) {

	empty_options := k8s.NewKubectlOptions("", "", "")

	// Enable proxy side car injection for ASM

	// First get the ASM label to apply by running:  kubectl -n istio-system describe pods -l app=istiod | grep REVISION | sort -u | awk '{print $2}'
	istio_get_label := "kubectl -n istio-system describe pods -l app=istiod | grep REVISION | sort -u | awk '{print $2}'"
	cmd := shell.Command{
		Command: "bash",
		Args:    []string{"-c", istio_get_label},
	}

	asm_label := shell.RunCommandAndGetOutput(t, cmd)
	// check if the label starts with asm-
	assert.Contains(t, asm_label, "asm-")

	// Create the label
	label_to_apply := "istio.io/rev=" + asm_label

	// Enable sidecar injection by runnning: kubectl label namespace default istio-injection-  istio.io/rev=asm-label --overwrite
	k8s.RunKubectlE(t, empty_options, "label", "namespace", "default", "istio-injection-", label_to_apply, "--overwrite")
	k8s.
}

func TestAnthosConfigManagement(t *testing.T) {
	t.Parallel()

	// checknamespaces

}
