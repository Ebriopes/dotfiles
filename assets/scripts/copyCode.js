// This assumes that you're using Rouge; if not, update the selector
const codeBlocks = document.querySelectorAll(".highlight:has(pre)");

const copyCode = (buttonNode, codeNode, duration = 3000) => {
  const { innerText: buttonOriginalText } = buttonNode;
  const codeText = codeNode.innerText;
  const notificationMessage = `¡Text copied!\n
  "${codeText.slice(0, 50)}..."\n`;

  buttonNode.addEventListener("click", () => {
    // Copy the code to the user's clipboard
    window.navigator.clipboard.writeText(codeText);

    // Update the button text visually
    buttonNode.innerText = "Copied!";
    // (Optional) Toggle a class for styling the button
    buttonNode.classList.add("copied");

    Toastify({
      text: notificationMessage,
      duration,
      gravity: "bottom", // `top` or `bottom`
      position: "right", // `left`, `center` or `right`
      avatar: "/assets/images/copy.png",
      style: {
        background: "linear-gradient(to right, #00b09b, #96c93d)",
      },
      callback: () => {
        buttonNode.innerText = buttonOriginalText;
        buttonNode.classList.remove("copied");
      },
    }).showToast();
  });
};

//////////////////////////////////////////
// Add copy buttons to every block code //
//////////////////////////////////////////
codeBlocks.forEach((codeContainer) => {
  const code = codeContainer.querySelector("pre > code");
  const copyButton = document.createElement("button");
  const buttonContainer = document.createElement("div");

  buttonContainer.classList.add(["code-header"]);
  copyButton.classList.add(["btn"]);
  copyButton.innerText = "Copy";

  buttonContainer.append(copyButton);
  codeContainer.append(buttonContainer);

  copyCode(copyButton, code);
});
