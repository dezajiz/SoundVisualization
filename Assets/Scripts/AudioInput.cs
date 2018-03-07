using UnityEngine;
using System.Collections;
using DG.Tweening;

[RequireComponent(typeof(AudioSource))]
public class AudioInput : MonoBehaviour {
	
	AudioSource audioSource;
	string deviceName {get; set;}
	public GameObject _model;
	float currentMax = 0.0f;

	void Start() {
		audioSource = this.GetComponent<AudioSource>();
		audioSource.loop = true;
		audioSource.clip = Microphone.Start(deviceName, true, 10, 44100);
		while (!(Microphone.GetPosition(deviceName) > 0)) { }
		audioSource.Play();
	}

	void Update() {
		float[] spectrum = new float[256];
		audioSource.GetSpectrumData(spectrum, 0, FFTWindow.Rectangular);

		int maxIndex = 0;
		float maxValue = 0.0f;

		for (int i = 0; i < spectrum.Length; i++) {
			var val = spectrum[i];
			if (val > maxValue) {
				maxValue = val;
				maxIndex = i;
			}
		}

		var freq = maxIndex * AudioSettings.outputSampleRate / 2 / spectrum.Length;

		if (freq > 0) {
			currentMax = freq;
			setScale(freq);
		}
	}

	private void setScale(float req) {
		float scale = req * 0.001f;
		_model.transform.localScale = new Vector3(scale, scale, scale);
		// _model.transform.DOScale(new Vector3(1,1,1), 1).OnComplete(onEndReset);
	}

	private void onEndReset() {
		currentMax = 0;
	}
}