{ config, pkgs, username, ... }:

let
  # Override os-service-types to add missing typing-extensions dependency
  python3Packages = pkgs.python311Packages.override {
    overrides = self: super: {
      os-service-types = super.os-service-types.overridePythonAttrs (old: {
        propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [ self.typing-extensions ];
      });
    };
  };
in
{
programs.k9s = {
  enable = true;

  settings = {
    k9s = {
      ui = {
        skin = "catppuccin-latte";
      };
    };
  };

  skins = {
    catppuccin-latte = {
      k9s = {
        body = {
          fgColor    = "#4c4f69"; # text
          bgColor    = "#eff1f5"; # base
          logoColor  = "#8839ef"; # mauve
        };
        prompt = {
          fgColor      = "#4c4f69"; # text
          bgColor      = "#e6e9ef"; # mantle
          suggestColor = "#1e66f5"; # blue
        };
        help = {
          fgColor      = "#4c4f69"; # text
          bgColor      = "#eff1f5"; # base
          sectionColor = "#40a02b"; # green
          keyColor     = "#1e66f5"; # blue
          numKeyColor  = "#e64553"; # maroon
        };
        frame = {
          title = {
            fgColor        = "#179299"; # teal
            bgColor        = "#eff1f5"; # base
            highlightColor = "#ea76cb"; # pink
            counterColor   = "#df8e1d"; # yellow
            filterColor    = "#40a02b"; # green
          };
          border = {
            fgColor    = "#9ca0b0"; # overlay0
            focusColor = "#8839ef"; # mauve
          };
          menu = {
            fgColor    = "#4c4f69"; # text
            keyColor   = "#1e66f5"; # blue
            numKeyColor = "#e64553"; # maroon
          };
          crumbs = {
            fgColor     = "#4c4f69"; # text
            bgColor     = "#dce0e8"; # crust
            activeColor = "#8839ef"; # mauve
          };
          status = {
            newColor       = "#40a02b"; # green
            modifyColor    = "#1e66f5"; # blue
            addColor       = "#179299"; # teal
            errorColor     = "#d20f39"; # red
            highlightColor = "#ea76cb"; # pink
            killColor      = "#e64553"; # maroon
            completedColor = "#9ca0b0"; # overlay0
          };
          info = {
            fgColor      = "#179299"; # teal
            sectionColor = "#4c4f69"; # text
          };
        };
        views = {
          table = {
            fgColor     = "#4c4f69"; # text
            bgColor     = "#eff1f5"; # base
            cursorColor = "#ccd0da"; # surface0
            markColor   = "#fe640b"; # peach
            header = {
              fgColor     = "#4c4f69"; # text
              bgColor     = "#e6e9ef"; # mantle
              sorterColor = "#8839ef"; # mauve
            };
          };
          yaml = {
            keyColor   = "#1e66f5"; # blue
            colonColor = "#7c7f93"; # overlay2
            valueColor = "#40a02b"; # green
          };
          logs = {
            fgColor = "#4c4f69"; # text
            bgColor = "#eff1f5"; # base
            indicator = {
              fgColor = "#4c4f69"; # text
              bgColor = "#8839ef"; # mauve
            };
          };
        };
      };
    };
  };

  plugins = {
    toggle-helmrelease = {
      shortCut = "Shift-T";
      confirm = true;
      scopes = [ "helmreleases" ];
      description = "Toggle to suspend or resume a HelmRelease";
      command = "bash";
      background = false;
      args = [
        "-c"
        ''
          suspended=$(kubectl --context $CONTEXT get helmreleases -n $NAMESPACE $NAME -o=custom-columns=TYPE:.spec.suspend | tail -1);
          verb=$([ $suspended = "true" ] && echo "resume" || echo "suspend");
          flux $verb helmrelease --context $CONTEXT -n $NAMESPACE $NAME | less -K
        ''
      ];
    };

    toggle-kustomization = {
      shortCut = "Shift-T";
      confirm = true;
      scopes = [ "kustomizations" ];
      description = "Toggle to suspend or resume a Kustomization";
      command = "bash";
      background = false;
      args = [
        "-c"
        ''
          suspended=$(kubectl --context $CONTEXT get kustomizations -n $NAMESPACE $NAME -o=custom-columns=TYPE:.spec.suspend | tail -1);
          verb=$([ $suspended = "true" ] && echo "resume" || echo "suspend");
          flux $verb kustomization --context $CONTEXT -n $NAMESPACE $NAME | less -K
        ''
      ];
    };

    reconcile-git = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = [ "gitrepositories" ];
      command = "bash";
      background = false;
      args = [
        "-c"
        "flux reconcile source git --context $CONTEXT -n $NAMESPACE $NAME | less -K"
      ];
    };

    reconcile-hr = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = [ "helmreleases" ];
      command = "bash";
      background = false;
      args = [
        "-c"
        "flux reconcile helmrelease --context $CONTEXT -n $NAMESPACE $NAME | less -K"
      ];
    };

    reconcile-helm-repo = {
      shortCut = "Shift-Z";
      confirm = false;
      description = "Flux reconcile";
      scopes = [ "helmrepositories" ];
      command = "bash";
      background = false;
      args = [
        "-c"
        "flux reconcile source helm --context $CONTEXT -n $NAMESPACE $NAME | less -K"
      ];
    };

    reconcile-oci-repo = {
      shortCut = "Shift-Z";
      confirm = false;
      description = "Flux reconcile";
      scopes = [ "ocirepositories" ];
      command = "bash";
      background = false;
      args = [
        "-c"
        "flux reconcile source oci --context $CONTEXT -n $NAMESPACE $NAME | less -K"
      ];
    };

    reconcile-ks = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = [ "kustomizations" ];
      command = "bash";
      background = false;
      args = [
        "-c"
        "flux reconcile kustomization --context $CONTEXT -n $NAMESPACE $NAME | less -K"
      ];
    };

    reconcile-ir = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = [ "imagerepositories" ];
      command = "sh";
      background = false;
      args = [
        "-c"
        "flux reconcile image repository --context $CONTEXT -n $NAMESPACE $NAME | less -K"
      ];
    };

    reconcile-iua = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = [ "imageupdateautomations" ];
      command = "sh";
      background = false;
      args = [
        "-c"
        "flux reconcile image update --context $CONTEXT -n $NAMESPACE $NAME | less -K"
      ];
    };

    toggle-rset = {
      shortCut = "Shift-T";
      confirm = false;
      scopes = [ "resourcesets" ];
      description = "Toggle to suspend or resume a ResourceSet";
      command = "bash";
      background = false;
      args = [
        "-c"
        ''
          reconcile=$(kubectl --context $CONTEXT get resourceset -n $NAMESPACE $NAME -o=custom-columns='TYPE:.metadata.annotations.fluxcd\.controlplane\.io/reconcile' | tail -1);
          verb=$([ $reconcile = "disabled" ] && echo "resume" || echo "suspend");
          flux-operator $verb rset --kube-context $CONTEXT -n $NAMESPACE $NAME | less -K
        ''
      ];
    };

    toggle-inputprovider = {
      shortCut = "Shift-T";
      confirm = false;
      scopes = [ "resourcesetinputprovider" ];
      description = "Toggle to suspend or resume an InputProvider";
      command = "bash";
      background = false;
      args = [
        "-c"
        ''
          reconcile=$(kubectl --context $CONTEXT get resourcesetinputprovider -n $NAMESPACE $NAME -o=custom-columns='TYPE:.metadata.annotations.fluxcd\.controlplane\.io/reconcile' | tail -1);
          verb=$([ $reconcile = "disabled" ] && echo "resume" || echo "suspend");
          flux-operator $verb inputprovider --kube-context $CONTEXT -n $NAMESPACE $NAME | less -K
        ''
      ];
    };

    reconcile-rset = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = [ "resourcesets" ];
      command = "bash";
      background = false;
      args = [
        "-c"
        "flux-operator reconcile rset --kube-context $CONTEXT -n $NAMESPACE $NAME | less -K"
      ];
    };

    reconcile-inputprovider = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = [ "resources" ];
      command = "bash";
      background = false;
      args = [
        "-c"
        "flux-operator reconcile inputprovider --kube-context $CONTEXT -n $NAMESPACE $NAME | less -K"
      ];
    };

    reconcile-fluxinstance = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = [ "fluxinstances" ];
      command = "bash";
      background = false;
      args = [
        "-c"
        "flux-operator reconcile instance --kube-context $CONTEXT -n $NAMESPACE $NAME | less -K"
      ];
    };

    trace = {
      shortCut = "Shift-Q";
      confirm = false;
      description = "Flux trace";
      scopes = [ "all" ];
      command = "bash";
      background = false;
      args = [
        "-c"
        ''
          if [ -n "$RESOURCE_GROUP" ]; then api_endpoint="/apis/$RESOURCE_GROUP/$RESOURCE_VERSION"; else api_endpoint="/api/$RESOURCE_VERSION"; fi;
          api_resource=$(kubectl get --raw "''${api_endpoint}" | jq -r ".resources[] | select(.name==\"$RESOURCE_NAME\")");
          kind=$(echo ''${api_resource} | jq -r '.kind');
          namespace_arg=$(echo ''${api_resource} | jq -r "if .namespaced == true then \"--namespace $NAMESPACE\" else \"\" end");
          [ -n "$RESOURCE_GROUP" ] && api_version=$RESOURCE_GROUP/;
          api_version=''${api_version}$RESOURCE_VERSION;
          flux trace --context $CONTEXT --kind ''${kind} --api-version ''${api_version} ''${namespace_arg} $NAME |& less -K
        ''
      ];
    };

    get-suspended-helmreleases = {
      shortCut = "Shift-S";
      confirm = false;
      description = "Suspended Helm Releases";
      scopes = [ "helmrelease" ];
      command = "sh";
      background = false;
      args = [
        "-c"
        ''
          kubectl get --context $CONTEXT --all-namespaces helmreleases.helm.toolkit.fluxcd.io -o json \
          | jq -r '.items[] | select(.spec.suspend==true) | [.metadata.namespace,.metadata.name,.spec.suspend] | @tsv' \
          | less -K
        ''
      ];
    };

    get-suspended-kustomizations = {
      shortCut = "Shift-S";
      confirm = false;
      description = "Suspended Kustomizations";
      scopes = [ "kustomizations" ];
      command = "sh";
      background = false;
      args = [
        "-c"
        ''
          kubectl get --context $CONTEXT --all-namespaces kustomizations.kustomize.toolkit.fluxcd.io -o json \
          | jq -r '.items[] | select(.spec.suspend==true) | [.metadata.name,.spec.suspend] | @tsv' \
          | less -K
        ''
      ];
    };
  };
};
}
