using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class Rotation : MonoBehaviour {

	float rotateX;
	float rotateY;
	float rotateZ;
	private Vector3 inititalPos;
	private Tweener tweenMove;
	private Tweener tweenScale;
	private float threshold;
	private int scene = 0;
	
	void Start () {
		rotateX = Random.Range(1, 360);
		rotateY = Random.Range(1, 360);
		rotateZ = Random.Range(1, 360);
		threshold = Random.Range(1.0f, 5.0f);
	}
	// Update is called once per frame
	void Update () {

		if (scene == 0) {
			gameObject.transform.rotation = Quaternion.Euler(rotateX, rotateY, rotateZ);
			rotateX += 2;
			rotateY += 2;
			rotateZ += 2;
		}

		if (Input.GetKey(KeyCode.Space)) {
			if (scene == 0) {

			} else if (scene == 1) {

			}

			if (tweenScale != null) {
				tweenScale.Kill();
			}

			int scale = Mathf.FloorToInt(Random.Range(0.5f, 1.0f));
			transform.localScale = new Vector3(scale, scale, scale);

			// 位置とスケールを戻す
			tweenScale = transform.DOScale(new Vector3(0.1f, 0.1f, 0.1f), 0.3f);
		} else if (Input.GetKey(KeyCode.M)) {
			scene++;
			if (scene == 1) {
				Move();
			}
		}
	}

	void Move () {
		// transform.DOScale(new Vector3(1.0f, 1.0f, 1.0f), 2.0f).SetEase(Ease.InOutCirc);
		transform.DORotate(new Vector3(0.0f, 0.0f, 0.0f), 2.0f).SetEase(Ease.InOutCirc);
	}
}
