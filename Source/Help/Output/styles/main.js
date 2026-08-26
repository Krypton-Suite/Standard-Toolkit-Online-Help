// Use container fluid
var containers = $(".container");
containers.removeClass("container");
containers.addClass("container-fluid");

// Navbar Hamburger
$(function() {
    $(".navbar-toggle").click(function() {
        $(this).toggleClass("change");
    })
})

// Select list to replace affix on small screens
$(function () {
    var navItems = $(".sideaffix .level1 > li");

    if (navItems.length == 0) {
        return;
    }

    var selector = $("<select/>");
    selector.addClass("form-control visible-sm visible-xs");
    var form = $("<form/>");
    form.append(selector);
    form.prependTo("article");

    selector.change(function() {
        window.location = $(this).find("option:selected").val();
    })

    function work(item, level) {
        var link = item.children('a');

        var text = link.text();
        
        for (var i = 0; i < level; ++i) {
            text = '&nbsp;&nbsp;' + text;
        }

        selector.append($('<option/>', {
            'value': link.attr('href'),
            'html': text
        }));

        var nested = item.children('ul');

        if (nested.length > 0) {
            nested.children('li').each(function () {
                work($(this), level + 1);
            });
        }
    }

    navItems.each(function () {
        work($(this), 0);
    });
})

document.addEventListener("DOMContentLoaded", () => {
  // Version switcher for multi-branch sites (/master/, /alpha/, /v105-lts/)
  (function insertVersionSwitcher() {
    const versions = [
      { slug: "master", label: "Master" },
      { slug: "alpha", label: "Alpha" },
      { slug: "v105-lts", label: "V105-LTS" }
    ];
    const match = location.pathname.match(/^(.*\/)?(master|alpha|v105-lts)(\/|$)/i);
    if (!match) {
      return;
    }
    const prefix = match[1] || "/";
    const current = match[2].toLowerCase();
    const nav = document.querySelector(".navbar-nav") || document.querySelector("header nav ul");
    if (!nav) {
      return;
    }
    const li = document.createElement("li");
    li.className = "krypton-version-switcher";
    const select = document.createElement("select");
    select.setAttribute("aria-label", "Documentation version");
    select.title = "Toolkit branch for API docs";
    versions.forEach((v) => {
      const opt = document.createElement("option");
      opt.value = prefix + v.slug + "/";
      opt.textContent = v.label;
      if (v.slug === current) {
        opt.selected = true;
      }
      select.appendChild(opt);
    });
    select.addEventListener("change", () => {
      location.href = select.value;
    });
    li.appendChild(select);
    nav.appendChild(li);
  })();

  document.querySelectorAll("pre > code").forEach((codeBlock) => {
    const button = document.createElement("button");
    button.className = "copy-code-button";
    button.innerHTML = '<i class="fa fa-clipboard"></i> Copy';
    button.setAttribute("title", "Copy code to clipboard");

    codeBlock.parentNode.insertBefore(button, codeBlock);

    button.addEventListener("click", async () => {
      try {
        await navigator.clipboard.writeText(codeBlock.textContent);
        button.innerHTML = '<i class="fa fa-check"></i> Copied!';
        button.classList.add("copied");
        setTimeout(() => {
          button.innerHTML = '<i class="fa fa-clipboard"></i> Copy';
          button.classList.remove("copied");
        }, 1500);
      } catch (err) {
        // Fallback for older browsers
        const textArea = document.createElement("textarea");
        textArea.value = codeBlock.textContent;
        document.body.appendChild(textArea);
        textArea.select();
        try {
          document.execCommand('copy');
          button.innerHTML = '<i class="fa fa-check"></i> Copied!';
          button.classList.add("copied");
          setTimeout(() => {
            button.innerHTML = '<i class="fa fa-clipboard"></i> Copy';
            button.classList.remove("copied");
          }, 1500);
        } catch (fallbackErr) {
          button.innerHTML = '<i class="fa fa-times"></i> Failed';
          setTimeout(() => (button.innerHTML = '<i class="fa fa-clipboard"></i> Copy'), 1500);
        }
        document.body.removeChild(textArea);
      }
    });
  });

  // Dynamically update copyright year in footer
  const currentYear = new Date().getFullYear();
  const footer = document.querySelector('.footer');
  if (footer) {
    footer.innerHTML = footer.innerHTML.replace(/2017 - \d{4}/g, `2017 - ${currentYear}`);
  }
});
