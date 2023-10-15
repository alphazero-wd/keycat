import { specialKeys } from "./special_keys";
import { calculateAccuracy, calculateProgress, calculateWpm } from "./utils";

export class Typing {
  constructor(channel) {
    this.typingParagraphEl = document.getElementById("typing-paragraph");
    this.typingBox = document.getElementById("typing-box");
    this.prevError = null;
    this.typos = 0;
    this.charTyped = 0;
    this.channel = channel;
    this.typingParagraph = this.typingParagraphEl.textContent;
    this.is_game_finished = false;
  }

  load() {
    this.preventCheating();
    this.onKeydown();
    this.startedAt = new Date().getTime();
  }

  preventCheating() {
    this.typingBox.addEventListener("paste", (e) => e.preventDefault()); // prevent copy and paste
    this.typingParagraphEl.addEventListener("select", (e) =>
      e.preventDefault()
    ); // prevent select
  }

  onKeydown() {
    this.typingBox.addEventListener("keydown", (e) => {
      let highlightedText = "";
      if (e.key === "Backspace") {
        if (this.prevError === null) e.preventDefault();
        else {
          this.charTyped--;
          highlightedText =
            `<mark class="correct">${this.typingParagraph.substring(
              0,
              this.charTyped
            )}</mark>` + this.typingParagraph.substring(this.charTyped);

          this.typingParagraphEl.innerHTML = highlightedText;
          this.prevError = null;
        }
      } else if (!this.isSpecialKeyPressed(e.key) && this.prevError === null) {
        let classNameBasedOnCorrectness = "";

        if (this.typingParagraph[this.charTyped] === e.key) {
          if (e.key === " ") {
            this.typingBox.value = "";
            this.channel.push("progress", {
              progress: calculateProgress(this.charTyped, this.typingParagraph),
            });
          }
          classNameBasedOnCorrectness = "correct";
        } else {
          this.prevError = this.charTyped;
          this.typos++;
          classNameBasedOnCorrectness = "incorrect";
        }

        highlightedText =
          `<mark class="correct">${this.typingParagraph.substring(
            0,
            this.charTyped
          )}</mark>` +
          `<mark class="${classNameBasedOnCorrectness}">${this.typingParagraph.charAt(
            this.charTyped
          )}</mark>` +
          this.typingParagraph.substring(this.charTyped + 1);
        this.typingParagraphEl.innerHTML = highlightedText;
        this.charTyped++;
        this.onFinishTyping();
      } else {
        e.preventDefault();
      }
    });
  }

  onFinishTyping() {
    if (this.charTyped === this.typingParagraph.length) {
      const timeTaken = Date.now() - this.startedAt;
      this.saveResult(timeTaken);
      this.is_game_finished = true;
      this.onEnd();
    }
  }

  onEnd() {
    this.typingParagraphEl.style.display = "none";
    this.typingBox.blur();
    this.typingBox.style.display = "none";
  }

  isSpecialKeyPressed(key) {
    const specialKeysSet = new Set(specialKeys);
    return specialKeysSet.has(key);
  }

  saveResult(timeTaken) {
    this.channel.push("player_finished", {
      time_taken: timeTaken,
      progress: calculateProgress(this.charTyped, this.typingParagraph),
      wpm: calculateWpm(this.charTyped, timeTaken),
      acc: calculateAccuracy(this.typos, this.charTyped),
    });
  }
}
